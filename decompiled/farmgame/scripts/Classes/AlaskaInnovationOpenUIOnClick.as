package Classes
{
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   
   public class AlaskaInnovationOpenUIOnClick extends FeatureBuilding
   {
      
      public function AlaskaInnovationOpenUIOnClick(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onClick() : void
      {
         var prereq:String = null;
         if(!Global.worldManager.isVisiting())
         {
            prereq = this.getItem().marketPrereqName;
            if(DreamWorldInnovationManager.getInstance("AlaskaInnovation"))
            {
               DreamWorldInnovationManager.getInstance("AlaskaInnovation").showMainUI();
            }
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         if(DreamWorldInnovationManager.getInstance("AlaskaInnovation"))
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

