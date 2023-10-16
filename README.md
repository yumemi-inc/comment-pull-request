[![CI](https://github.com/yumemi-inc/comment-pull-request/actions/workflows/ci.yml/badge.svg)](https://github.com/yumemi-inc/comment-pull-request/actions/workflows/ci.yml)

# Comment Pull Request

A GitHub Action for commenting on pull requests from workflows.
Previous comments by the same job are deleted (or hidden or edited), thus avoiding flooding reports of checks based on old commits.

## Usage

See [action.yml](action.yml) for available action inputs.
Note that this action requires `pull-requests: write` permission.

### Minimal usage

You only need to specify `comment` input.

```yaml
- uses: yumemi-inc/comment-pull-request@v1
  with:
    comment: |
      Pull request check passed successfully.
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
      Pull request check passed successfully.
```

Comments are grouped by the value of `grouping-key` input (default is `${{ github.workflow }}-${{ github.job }}`), and comments in the same group are subject to deletion, etc.

## Tips

It is often necessary to separate the contents of comments when a check passes and when it fails. You can define it in one step by using `comment-if-failure` input.

```yaml
- run: npm run test
- uses: yumemi-inc/comment-pull-request@v1
  if: cancelled() != true
  with:
    comment: |
      Pull request check passed successfully.
    comment-if-failure: |
      @${{ github.actor }} Pull request check failed.

      See details [here](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}).
```
