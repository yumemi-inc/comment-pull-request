[![CI](https://github.com/yumemi-inc/comment-pull-request/actions/workflows/ci.yml/badge.svg)](https://github.com/yumemi-inc/comment-pull-request/actions/workflows/ci.yml)

# Comment Pull Request

A GitHub Action for commenting on pull requests from workflows.
Previous comments by the same job are deleted (or hidden or edited), thus avoiding flooding reports of checks based on old commits.

## Usage

See [action.yml](action.yml) for available action inputs.
Note that this action requires `pull-requests: write` permission.

### Supported workflow trigger events

Basically, this action is used in `pull_request` events, but you can use it in any trigger by specifying `pull-request-number` input (default is `${{ github.event.pull_request.number }}`).

Even if this input is omitted, the pull request number will be searched for using the commit SHA specified in `sha` input (default is `${{ github.sha }}`), but if it cannot be found, explicitly specify `pull-request-number` input.
For example, in the case of [merge queue](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue), you cannot search using `${{ github.sha }}`, so do it like [this](https://github.com/yumemi-inc/comment-pull-request/blob/33fd83e2b15e09d164f6cc6d4ee26aa6a1fd3cd6/.github/workflows/ci.yml#L25-L29).

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

### Fail workflows for CI

If you want the workflow to fail along with the comment, specify `true` for `fail` input.

## Tips

### Comment file contents

Sample workflow for commenting file contents.

```yaml
- id: sample
  run: |
    ls -al > ./sample.txt
    {
      delimiter="$(openssl rand -hex 8)"
      echo "file<<$delimiter"
      cat ./sample.txt
      echo "$delimiter"
    } >> "$GITHUB_OUTPUT"
- uses: yumemi-inc/comment-pull-request@v1
  with:
    comment: |
      <details>
      <summary>sample.txt</summary>

      ${{ steps.sample.outputs.file }}
      </details>
```

ref: [Multiline strings](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings)

### User mention

Write the account name after `@`.
For example, to mention the creator of a pull request, write as follows:

```yaml
comment: |
  @${{ github.actor }} A critical error has occurred.
```

### Guide to job logs and summaries

The URL for the job log and [summary](https://github.blog/2022-05-09-supercharging-github-actions-with-job-summaries/) is `https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}`.

To guide this URL with comments, write as follows;

```yaml
comment: |
  Some tests failed.

  See details from [here](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}).
```

It is recommended to write reports such as test results and coverage in the summary rather than in comments.
