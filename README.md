## Ruby ETL Tool using Kiba Gem

This repository contains a Ruby ETL (Extract, Transform, Load) tool built on top of the Kiba gem. It facilitates copying data from one table to another table, with the ability to define custom transformation steps. The tool loads the pipeline definition from a YAML file, allowing for easy configuration and customization.

### Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
    - [Installation](#installation)
    - [Configuration](#configuration)
    - [Running the ETL](#running-the-etl)
- [Pipeline Definition](#pipeline-definition)
- [Transformations](#transformations)
- [Resources](#resources)
- [Contributing](#contributing)
- [License](#license)

### Introduction

This ETL tool is designed to efficiently transfer data between tables in different databases. It leverages the power of Kiba, a lightweight, flexible ETL framework for Ruby, for defining and executing data processing pipelines.

### Usage

#### Installation

To use this ETL tool, you need to have Ruby installed on your system. You can install the necessary dependencies by running:

```bash
bundle install
```

#### Configuration

The pipeline definition is loaded from a YAML file. You can customize the source, destination, and any transformation steps in this YAML file.

#### Running the ETL

To execute the ETL process, run the following command:

```bash
bundle exec ruby etl.rb
```

### Pipeline Definition

The pipeline definition is structured in a YAML format, specifying the source, transformation steps (optional), and destination. Below is an example YAML file:

```yaml
- pipeline:
  name: 'Sync agents from rently to armor'
  source:
    class: 'Postgres::Source::Base'
    attributes:
      database_name: 'rently'
      table_name: 'agents'
      columns:
        - id
        - email
        # Add more source columns as needed

  transforms:
    - class: 'Transforms::ValueCopy'
      attributes:
        columns_map:
          updated_at: 'rently_agent_last_updated'

    - class: 'Transforms::ColumnRename'
      attributes:
        columns_map:
          id: 'rently_id'
          # Add more column renaming as needed

  destination:
    class: 'Postgres::Destination::Base'
    attributes:
      database_name: 'armor'
      table_name: 'agent_identities'
      columns:
        - email
        - id
        # Add more destination columns as needed
      primary_key: 'id'
```

### Sources
The sources are components responsible for the extraction of data.

#### Postgres Source
**class name :** `Postgres::Source::Base` Retrieves data from a PostgreSQL database.
```
    database_name: The name of the PostgreSQL database.
    table_name: The name of the table to extract data from.
    columns: An array of column names to extract from the table.
```

#### Creating custom sources
Sources are classes implementing:

 - a constructor (to which Kiba will pass the provided arguments in the DSL)
 - the `each` method (which should yield rows one by one)

check Kiba documentation for more info : https://github.com/thbar/kiba/wiki/Implementing-ETL-sources

Rows are usually Hash instances, but could be other structures as long as the next steps of your pipeline know how to handle them. 
Since sources are classes, you can (and are encouraged to) unit test them and reuse them.

### Destinations / Sinks

Destinations are components responsible for the writing of data to a destination.

#### Postgres Destination
**class name :** `Postgres::Destination::Base`

Writes data to a PostgreSQL database.
```
    database_name: The name of the PostgreSQL database.
    table_name: The name of the table to write data to.
    columns: An array of column names to write to the table.
    primary_key: The primary key column of the destination table.
```

#### Creating custom destinations
Like sources, destinations are classes that you are providing. Destinations must implement:

- a constructor (to which Kiba will pass the provided arguments in the DSL)
- a write(row) method that will be called for each non-dismissed row
- an optional close method (only called if no error was raised - see notes below on handling resources)

check Kiba documentation for more info : https://github.com/thbar/kiba/wiki/Implementing-ETL-destinations

### Transformations

Transformations are optional and allow you to manipulate data during the ETL process. 
Examples of transformations include renaming columns, copying values, or performing calculations.

#### Available Transforms
1. ValueCopy : Copies values from one column to another.
    ``` 
        columns_map: A hash mapping source column names to destination column names.
    ```

2. ColumnRename : Renames columns according to the specified mapping.
    ```
        columns_map: A hash mapping original column names to new column names.
    ```

#### Creating custom transformations
A Kiba transform is a Ruby class with:

- a constructor (used for configuration)
- a process(row) method (responsible for preparing output rows based on an input row)
- optional: a close method (useful for "yielding transforms" in particular, see next section)

check Kiba documentation for more info : https://github.com/thbar/kiba/wiki/Implementing-ETL-transforms

### File Structure

- `config/` : This directory contains configuration files for the project.
    - `database.yml` : Stores database connection settings, If you want to add a new database to the
        project, you can add the connection settings here.
    


- `kiba.rb` : Entry point for the Kiba ETL tool. This file may define global settings or require other necessary files.

- `lib/` : This directory typically holds additional Ruby libraries or modules used in the project.

- `pipelines/` : Contains YAML files defining ETL pipeline configurations.
              If you want to add a new pipeline, you can add a new YAML file here. Single YAML 
              file can contain multiple pipelines.

- `src/` : Source code directory.
    - `pipelines/` : Contains Ruby files related to pipeline execution.
    - `postgres/` : Directory for PostgreSQL related code. 
    - `transforms/`: Contains classes for data transformation.


### Resources

- [Kiba Documentation](https://github.com/thbar/kiba)

### Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve this ETL tool.

### License

This project is licensed under the [MIT License](LICENSE).