
  List = do ->

    accept = (list, predicate) -> [ item for item, index in list when predicate item, index ]
    reject = (list, predicate) -> [ item for item, index in list when not predicate item, index ]

    map = (list, fn) -> [ (fn item, index) for item, index in list ]

    {
      accept, reject,
      map
    }