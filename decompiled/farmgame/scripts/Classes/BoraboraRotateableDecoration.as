package Classes
{
   import Classes.util.ZLocUtils;
   
   public class BoraboraRotateableDecoration extends RotateableDecoration
   {
      
      public function BoraboraRotateableDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function getMenuItems() : Array
      {
         var items:Array = null;
         if(canRotate())
         {
            items = [{
               "label":ZLocUtils.t("FarmGame","Rotate"),
               "action":ROTATE_OBJECT
            },{
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            }];
         }
         else
         {
            items = super.getMenuItems();
         }
         return items;
      }
   }
}

