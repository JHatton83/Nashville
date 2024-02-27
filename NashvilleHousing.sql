--NashvilleHousing data cleaning walk through

Select *
from NashvilleHousing

--Standardize Data Format

Select Saledateconverted, convert(date, saledate)
from NashvilleHousing

Update NashvilleHousing
set saledate = convert(date, saledate)

Alter table NashvilleHousing
add Saledateconverted date;

Update NashvilleHousing
set Saledateconverted = convert(date, saledate)

-- Populate Property Address Data (populating blank values in the excel data in that column)

Select *
from NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNull (a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing as a
Join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.propertyaddress is null

Update a
set PropertyAddress = ISNull (a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing as a
Join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.propertyaddress is null

--Breaking out Address Into Individuald Columns (Address, city, State) --delimiter is something that separates diff values in same column

Select PropertyAddress	
from NashvilleHousing

Select
substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as StreetAddress
, substring (PropertyAddress, Charindex(',', PropertyAddress)+1, Len (propertyaddress)) as City
From NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

Alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = substring (PropertyAddress, Charindex(',', PropertyAddress)+1, Len (propertyaddress))

Select *	
from NashvilleHousing


Select OwnerAddress	
from NashvilleHousing

Select
Parsename (Replace (OwnerAddress,',','.'), 3) 
, Parsename (Replace (OwnerAddress,',','.'), 2)
, Parsename (Replace (OwnerAddress,',','.'), 1)
from NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = Parsename (Replace (OwnerAddress,',','.'), 3) 

Alter table NashvilleHousing
add OwnderSplitcity nvarchar(255);

Update NashvilleHousing
set OwnderSplitcity = Parsename (Replace (OwnerAddress,',','.'), 2)

Alter table NashvilleHousing
add OwnderSplitState nvarchar(255);

Update NashvilleHousing
set OwnderSplitState = Parsename (Replace (OwnerAddress,',','.'), 1)

Select *
from NashvilleHousing



-- Change Y and N to yes and No in "sold as vacant" field (if/then case statements)

Select Distinct (soldasvacant), count (SoldAsVacant)
from NashvilleHousing
Group by SoldasVacant
Order by 2


Select SoldAsVacant,
	Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsvacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsvacant = 'N' then 'No'
	else SoldAsVacant
	end






--Remove Duplicates (not standard practice to delete data from databases)

With RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	from NashvilleHousing								   
)
	
Select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress





--Delete Unused Columns (dont delete from raw data, best practice is to use to delete views you've created)

Select *
from NashvilleHousing

Alter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
Drop Column SaleDate
