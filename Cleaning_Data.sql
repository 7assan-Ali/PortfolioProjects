/*
Cleaning Data in SQL Queries
*/


select * 
from Nashville_Housing_Data_Cleaning
---------------------------------------------------------------------------
--Standaries Data Format
select SaleDate,convert(Date,saledate)
from Nashville_Housing_Data_Cleaning


update Nashville_Housing_Data_Cleaning
set SaleDate=convert(date,SaleDate)--when i call column the column is not convert

alter table Nashville_Housing_Data_Cleaning
add saleDateConverted Date;--add new column 

update Nashville_Housing_Data_Cleaning
set saleDateConverted=convert(date,SaleDate)

select *
from Nashville_Housing_Data_Cleaning


----------------------------------------------------------
-- Populate Property address Data
select *
from Nashville_Housing_Data_Cleaning
where propertyaddress is null
order by parcelid

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,isnull(a.PropertyAddress,b.PropertyAddress) as new_address
from Nashville_Housing_Data_Cleaning a
join Nashville_Housing_Data_Cleaning b
    on a.parcelid=b.parcelid
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)--isnull(oldvalue,newvalue)
from Nashville_Housing_Data_Cleaning a
join Nashville_Housing_Data_Cleaning b
     on a.parcelid=b.parcelid
	  and a.[UniqueID ]<>b.[UniqueID ]
where a.propertyaddress is null

select *
from Nashville_Housing_Data_Cleaning


--------------------------------------------------------------------


--Breaking out address into individual columns (address ,city, state)
-- ????? ??? ???????? ?',' 
 
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
--,CHARINDEX(',',PropertyAddress)
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from Nashville_Housing_Data_Cleaning



alter table Nashville_Housing_Data_Cleaning
add PropertySplitAddress nvarchar(255);--add new column 

update Nashville_Housing_Data_Cleaning
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 



alter table Nashville_Housing_Data_Cleaning
add PropertySplitAddressCity nvarchar(255);--add new column 

update Nashville_Housing_Data_Cleaning
set PropertySplitAddressCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select *
from Nashville_Housing_Data_Cleaning
where PropertyAddress is null




select OwnerAddress
from Nashville_Housing_Data_Cleaning


select 
PARSENAME(replace(OwnerAddress,',','.'),1)as zip,
PARSENAME(replace(OwnerAddress,',','.'),2) as state,
PARSENAME(replace(OwnerAddress,',','.'),3)as street

from Nashville_Housing_Data_Cleaning


alter table Nashville_Housing_Data_Cleaning
add OwnerZip nvarchar(255);--add new column 

update Nashville_Housing_Data_Cleaning
set OwnerZip=PARSENAME(replace(OwnerAddress,',','.'),1)



alter table Nashville_Housing_Data_Cleaning
add ownerstate nvarchar(255);--add new column 

update Nashville_Housing_Data_Cleaning
set ownerstate=PARSENAME(replace(OwnerAddress,',','.'),2)


alter table Nashville_Housing_Data_Cleaning
add ownerstreet nvarchar(255);--add new column 

update Nashville_Housing_Data_Cleaning
set ownerstreet=PARSENAME(replace(OwnerAddress,',','.'),3)

select *
from Nashville_Housing_Data_Cleaning


------------------------------------------------------------------------------------------

--change x and n to yes and no in "Sold as vacan" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from Nashville_Housing_Data_Cleaning
group by SoldAsVacant
order by 2

select distinct(SoldAsVacant),count(SoldAsVacant)
from Nashville_Housing_Data_Cleaning
group by SoldAsVacant



select SoldAsVacant,
  case 
	when SoldAsVacant ='Y'Then 'Yes'
	When SoldAsVacant='N'then 'No'
	else SoldAsVacant
	end
from Nashville_Housing_Data_Cleaning


update Nashville_Housing_Data_Cleaning
set SoldAsVacant=case 
	when SoldAsVacant ='Y'Then 'Yes'
	When SoldAsVacant='N'then 'No'
	else SoldAsVacant
	end


select distinct(SoldAsVacant),count(SoldAsVacant)
from Nashville_Housing_Data_Cleaning
group by SoldAsVacant
order by 2

------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplication
select *,ROW_NUMBER()over(
		partition by parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by 
					uniqueid
				)row_num		   
from Nashville_Housing_Data_Cleaning
order by ParcelID
--CTE
with row_num_CTE as(
select *
      ,ROW_NUMBER()over(
		partition by parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by 
					uniqueid
				)row_num		   
from Nashville_Housing_Data_Cleaning
--order by ParcelID
)
select *
from row_num_CTE
where row_num>1
order by PropertyAddress
--delete 
--from row_num_CTE
--where row_num>1
----order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--delete unused column
Select *
from Nashville_Housing_Data_Cleaning

alter table Nashville_Housing_Data_Cleaning
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table Nashville_Housing_Data_Cleaning
drop column SaleDate