```
/ssm max_number
```
To set a max of shards (saved per character), 0 is infinite

```
/ssm
```
To delete if you have too much shards. Just macro it into Life Tap or Drain Soul or by itself.
It cannot be fully automatic after combat because the related wow api needs a hardware event.

It delete in priority outside your soul bag, from right to left inside your bags, and takes into account the `GetInsertItemsLeftToRight` variable to delete from the bag supposed to be filled first.
