# EMODnet
Processing EMODnet data

***
### [Data files](/data)

The "data/" folder contains three EMODNET data files:

- **Black_Sea_BIOTA.txt**
- **data_from_Mediterranean_Biota_Contaminants.txt**
- **data_from_Mediterranean_Biota_Contaminants_Time_series.txt**

Received 23-05-2018 from <cite>Eugenia Molina</cite> mmolinajack@inogs.it

The folder also contains the following file with P01 codes and their meanings:

- **P01_subcomponents.txt**

***
### [Generate_P01_table.R](Generate_P01_table.R)
Restructures the data for P01 codes in the file **P01_subcomponents.txt** and saves this as **P01.txt** in the base folder for the project. 

***
### [Read_P01_table.R](Read_P01_table.R)
Reads the table of P01 data **P01.txt**. This is used to link restructured EMODNET data to P01 information e.g. species, measurement basis, etc. 

***
### [convert.R](convert.R)
The EMODNET odv files are in "wide" format with each measurement parameter in a separate column. The *convert()* function transforms EMODNET data to a "long" format with each observation on a separate line. 

***
### [main.R](main.R)
This script does the following:

- loads P01 data using *Read_P01_table.R*
- calls the *convert()* function to transform each of the three EMODNET data files.
- links the transformed files to P01 information
- merges the three datasets
- saves the result as **EMODNET_contaminants.txt**


