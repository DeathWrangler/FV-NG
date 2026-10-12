package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Display.HUD.HUD;
   import Managers.JMInnovationManager;
   import Managers.OlyInnovationManager;
   
   public class FeatureBuildingOpenUIOnClick extends FeatureBuilding
   {
      
      public function FeatureBuildingOpenUIOnClick(itemName:String = null)
      {
         super(itemName);
         this.updateState();
      }
      
      override public function onClick() : void
      {
         var prereq:String = null;
         if(!Global.worldManager.isVisiting())
         {
            prereq = this.getItem().marketPrereqName;
            if(prereq == "" || prereq == null || PrerequisiteUtility.checkPrereqByName(prereq))
            {
               displayStorageDialog();
            }
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var farmItem:FarmItem = null;
         var timeLeft:Number = NaN;
         var toolTip:String = null;
         var activeBuffCode:String = JMInnovationManager.getInstance().getActiveBuff(this.getItem().code);
         if(activeBuffCode)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(activeBuffCode);
            timeLeft = JMInnovationManager.getInstance().getTimeLeftForActiveBuff();
            toolTip = farmItem.friendlyTitle + " is active for " + HUD.getformattedTimeLeft(timeLeft);
            setToolTip(toolTip);
            updateToolTipPosition();
         }
         else
         {
            super.updateToolTipText();
         }
      }
      
      public function updateState() : void
      {
         var state:String = "built_0";
         var activeBuffCode:String = JMInnovationManager.getInstance().getActiveBuff(this.getItem().code);
         if(Boolean(activeBuffCode) || OlyInnovationManager.getInstance().isTotemRestored(this.getItemName()))
         {
            state = "built_1";
         }
         setState(state);
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
      
      override protected function determineState(delta:Number) : void
      {
         this.updateState();
      }
   }
}

