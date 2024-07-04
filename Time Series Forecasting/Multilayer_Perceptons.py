#Credits to https://learning.oreilly.com/library/view/python-for-finance/9781789618518/92ab89e6-344a-46de-8f98-71c5edcc661a.xhtml
Lewinson, Eryk. Python for Finance Cookbook. Packt Publishing, 2020.

import pandas as pd
from sklearn import preprocessing
import numpy as np
from numpy import array
 
# reading the CSV file
df = pd.read_csv('Houston HOU.csv', usecols= ['TMAX'])

#fill the NaN values with median values
df['TMAX'] = df['TMAX'].fillna(df['TMAX'].median())
 
# univariate data preparation
# split a univariate sequence into samples
def split_sequence(series, n_steps):
    X, Y = [], []
    for i in range(len(series) - n_steps):
        end_step = i + n_steps
        X.append(series[i:end_step])
        Y.append(series[end_step])
    return np.array(X), np.array(Y)

# choose a number of time steps
n_steps = 3

#Mini-batch: last twenty years
main_df = df.tail(7305)

# split into samples
X, Y = split_sequence(main_df['TMAX'].values, n_steps)


import torch
import torch.optim as optim
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import (Dataset, TensorDataset, 
                             DataLoader, Subset)
from sklearn.metrics import mean_squared_error

device = 'cuda' if torch.cuda.is_available() else 'cpu'

#Define the network's architecture
class MLP(nn.Module):
   
    def __init__(self, input_size):
        super(MLP, self).__init__()
        self.linear1 = nn.Linear(input_size, 4)
        #self.linear2 = nn.Linear(4, 4)
        self.output = nn.Linear(4, 1)
        self.dropout = nn.Dropout(p=0.2)
    
    
    def forward(self, x):
        x = self.linear1(x)
        x = F.relu(x)
        x = self.dropout(x)
        #x = self.linear2(x)
        #x = F.relu(x)
        #x = self.dropout(x)
        x = self.output(x)
        return x

# set seed for reproducibility
torch.manual_seed(42)

model = MLP(n_steps).to(device) 
loss_fn = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

X_tensor = torch.from_numpy(X).float()
Y_tensor = torch.from_numpy(Y).float().unsqueeze(dim=1)

#Create training and test sets
test_size = 1461 #same length of x_test for Julia methods
#test index
test_ind = len(X) - test_size

dataset = TensorDataset(X_tensor, Y_tensor)
train_dataset = Subset(dataset, list(range(test_ind)))
test_dataset = Subset(dataset, list(range(test_ind, len(X))))
train_loader = DataLoader(dataset=train_dataset,     
                          batch_size=12)
test_loader = DataLoader(dataset=test_dataset,
                          batch_size=12)

train_losses, test_losses = [], []
epochs = 2000

#Train the model
for epoch in range(epochs):
    running_loss_train = 0
    running_loss_test = 0

    model.train()
    
    for x_batch, y_batch in train_loader:
        
        # zero the parameter gradients
        optimizer.zero_grad()
        
        x_batch = x_batch.to(device)
        y_batch = y_batch.to(device)
        
        y_hat = model(x_batch)
        
        loss = loss_fn(y_batch, y_hat)
        loss.backward()
        optimizer.step()
        running_loss_train += loss.item() * x_batch.size(0)
        
    
    epoch_loss_train = running_loss_train / len(train_loader.dataset)
    train_losses.append(epoch_loss_train)

    with torch.no_grad():
        
        model.eval()
        
        for x_val, y_val in test_loader:
            x_val = x_val.to(device)
            y_val = y_val.to(device)
            y_hat = model(x_val)
            loss = loss_fn(y_val, y_hat)
            running_loss_test += loss.item() * x_val.size(0)
            
        
        epoch_loss_test = running_loss_test / len(test_loader.dataset)
            
        if epoch > 0 and epoch_loss_test < min(test_losses):
            best_epoch = epoch
            torch.save(model.state_dict(), './mlp_checkpoint.pth')
            
        test_losses.append(epoch_loss_test)

    if epoch % 50 == 0:
        print(f"<{epoch}> – Train. loss: {epoch_loss_train:.2f} \t Test loss: {epoch_loss_test:.2f}")
        
print(f'Lowest loss recorded in epoch: {best_epoch}')


import matplotlib.pyplot as plt
#Plot the losses over epochs
train_losses = np.array(train_losses)
test_losses = np.array(test_losses)

fig, ax = plt.subplots()

ax.plot(train_losses, color='blue', label='Training loss')
ax.plot(test_losses, color='red', label='Test loss')

ax.set(xlabel='Epoch', 
       ylabel='Loss')
ax.legend()

#Load the best model (with the lowest test loss):
state_dict = torch.load('mlp_checkpoint.pth')
model.load_state_dict(state_dict)

def mae(y_true, predictions):
    y_true, predictions = np.array(y_true), np.array(predictions)
    return np.mean(np.abs(y_true - predictions))

y_pred, y_test= [], []

with torch.no_grad():

    model.eval()
    
    for x_val, y_val in test_loader:
        x_val = x_val.to(device) 
        y_pred.append(model(x_val))
        y_test.append(y_val)
        
y_pred = torch.cat(y_pred).numpy().flatten()
y_test = torch.cat(y_test).numpy().flatten()

mlp_mae = mae(y_test, y_pred)

mlp_mse = mean_squared_error(y_test, y_pred)
mlp_rmse = np.sqrt(mlp_mse)
print(f"MLP's forecast – MAE: {mlp_mae:.2f}, RMSE: {mlp_rmse:.2f}")

fig, ax = plt.subplots()

ax.plot(y_pred, color='blue', label='forecast values')
ax.plot(y_test, color='red', label='observations')


ax.set(xlabel='Number of Days', 
       ylabel='Minimum Temperature')
ax.legend()

