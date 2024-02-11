# Clothes Tracker

A basic app to manually keep track of Laundry.

It can be in 3 main states

1. In the Closet and Ready to Use
2. In the Laundry Basket
3. At Laundry / In the wash

## Built Using

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)

## Database Schema

### Version 1

This is the initial version of the database schema. It is a simple schema with 1 table that holds the state of the clothes.

![Database Schema - Version 1](docs/database_schema/Version_1.png)

### Version 2

The second version of the database schema is a more complex schema with 3 tables. The first table holds the information of the clothes and the second table holds the names of the categories which are linked to the categories. The third table holds information regarding miscellaneous clothes like socks, undergarments, etc.

![Database Schema - Version 2](docs/database_schema/Version_2.png)