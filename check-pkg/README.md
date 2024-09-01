# flrsh-dev/cran-checks/check-pkg

Identifies if there are any failing CRAN check flavors for a published CRAN package. 

If the package does not exist on CRAN then the action will fail. If the package does exist and it only contains `NOTE` and `OK` check statuses, then the action will pass. 

The CRAN check statuses are updated once daily at `15:00 UTC`. It is recommended to run this check once after 15:00 UTC.


## Example usage

Here is an example workflow file that can be used. Copy the below into `.github/worflows/cran-checks.yaml` and set the `pkg:` input to your package's name.

```yaml
name: Check CRAN status

on:
  schedule:
    # Runs daily at 4:00 PM UTC (9:00 AM PST)
    - cron: '0 16 * * *'  
  # allows for manually running of the check
  workflow_dispatch:

jobs:
  check_cran_status:
    runs-on: ubuntu-latest

    steps:
      - name: Get CRAN checks
        uses: flrsh-dev/cran-checks/check-pkg@v0.1.0
        with:
          pkg: b64
```

## License

MIT / Apache 2.0
