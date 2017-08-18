# How to run csv_fast_importer gem?

- Start local PostgreSQL database

- Check connection settings in `config/database.yml`

- Setup database environement:

```bash
bundle exec rake db:setup
```

- Execute `csv_fast_importer` rake task:

```bash
bundle exec rake csv_fast_importe
```

- Verify following output:

```
2 knights imported.
```
