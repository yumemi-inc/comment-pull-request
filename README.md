[![CI](https://github.com/yumemi-inc/comment-pull-request/actions/workflows/ci.yml/badge.svg)](https://github.com/yumemi-inc/comment-pull-request/actions/workflows/ci.yml)

# Comment Pull Request

A GitHub Action for commenting on pull requests from workflows.
Previous comments by the same job are deleted (or hidden or edited), thus avoiding flooding reports of checks based on old commits.

## Usage

See [action.yml](action.yml) for available action inputs.
Note that this action requires `pull-requests: write` permission.

### Basic

Specify `comment` input.

```yaml
- uses: yumemi-inc/comment-pull-request@v1
  with:
    comment: |
      # Test coverage report

      ...
```

In this case, previous comments will be deleted.

### Change how previous comments are handled

By specifying `previous-comment` input, you can change the handling of previous comments.
Specify one of `delete` (default), `hide`, `edit`, or `keep` (do nothing).

```yaml
- uses: yumemi-inc/comment-pull-request@v1
  with:
    previous-comment: 'hide'
    comment: |
      # Test coverage report

      ...
```

Comments are grouped by the value of `grouping-key` input (default is `${{ github.workflow }}-${{ github.job }}`), and comments in the same group are subject to deletion, etc.

### Comments on failure

It is often necessary to separate the contents of comments when a check passes and when it fails. You can define it in one step by using `comment-if-failure` input.

```yaml
- run: npm run test
- uses: yumemi-inc/comment-pull-request@v1
  if: cancelled() != true
  with:
    comment: |
      :white_check_mark: All tests passed.
    comment-if-failure: |
      :no_entry_sign: Some tests failed.
      
      See test results from ...
```

## Tips

### User mention

Write the account name after `@`.
For example, to mention the creator of a pull request, write as follows:

```yaml
comment: |
  @${{ github.actor }} A critical error has occurred.
```

### Guide to job logs and summaries

The URL for the job log and summary is `https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}`.

About job summary: [Supercharging GitHub Actions with Job Summaries](https://github.blog/2022-05-09-supercharging-github-actions-with-job-summaries/)

To guide this URL with comments, write as follows;

```yaml
comment: |
  Some tests failed.

  See details from [here](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}).
```

It is recommended to write reports such as test results and coverage in the summary rather than in comments.
