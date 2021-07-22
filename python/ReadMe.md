# ReadMe.md

These python scripts are used to generate and clean data from the demo tables.

## Creating the CSV Files

Right now, the only script that is really used is the generate.py

```sh
python generate.py
```

That will create the CSV files that contain all of the data needed for the database. fully populated database with 4.1M ticket records for 41,000 flights.

All generated files will appear in the ```database/``` folder and any previous versions of those files will be deleted. Please refer to the [User's Guide](../UsersGuide.md) for how to crate your datbase with these files.

