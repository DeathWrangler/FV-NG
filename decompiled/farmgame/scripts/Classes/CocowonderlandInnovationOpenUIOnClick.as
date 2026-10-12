package Classes
{
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   
   public class CocowonderlandInnovationOpenUIOnClick extends FeatureBuilding
   {
      
      public function CocowonderlandInnovationOpenUIOnClick(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onClick() : void
      {
         var prereq:String = null;
         if(!Global.worldManager.isVisiting())
         {
            prereq = this.getItem().marketPrereqName;
            if(CocowonderlandInnovationManager.getInstance("CocowonderlandInnovation"))
            {
               CocowonderlandInnovationManager.getInstance("CocowonderlandInnovation").showMainUI();
            }
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         if(CocowonderlandInnovationManager.getInstance("CocowonderlandInnovation"))
         {
            toolTip = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
         }
         else
         {
            toolTip = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName()) + " has Expired";
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
   }
}

