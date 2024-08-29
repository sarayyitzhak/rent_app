
enum Condition{
  NEW('New', 0),
  USED_AS_NEW('Used as new', 1),
  USED_IN_GOOD_SHAPE('Used in good shape', 2),
  USED_IN_MEDIUM_SHAPE('Used in medium shape', 3);

  final String title;
  final int idx;
  const Condition(this.title, this.idx);
}

Condition getCondFromIdx(int idx){
  switch(idx){
    case 0:
      return Condition.NEW;
    case 1:
      return Condition.USED_AS_NEW;
    case 2:
      return Condition.USED_IN_GOOD_SHAPE;
    case 3:
      return Condition.USED_IN_MEDIUM_SHAPE;
  }
  return Condition.USED_IN_MEDIUM_SHAPE;
}