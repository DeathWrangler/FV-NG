package Classes
{
   import Managers.WhitewinterInnovationManager;
   
   public class WhiteWinterInnovationOpenUIOnClick extends FeatureBuilding
   {
      
      public function WhiteWinterInnovationOpenUIOnClick(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onClick() : void
      {
         var prereq:String = null;
         if(!Global.worldManager.isVisiting())
         {
            prereq = this.getItem().marketPrereqName;
            if(WhitewinterInnovationManager.getInstance())
            {
               displayStorageDialog();
            }
         }
      }
   }
}

