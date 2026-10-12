package GameMode
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TUseCSlotMachineToken;
   
   public class GMCSlotMachineToken extends GMTargetedConsumable
   {
      
      public function GMCSlotMachineToken(consumable:String, isGift:Boolean = true)
      {
         super(consumable,isGift);
      }
      
      override public function setupCusorLoader() : void
      {
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.setTargetObject();
         var buildingName:String = this.getBuildingName();
         if(m_targetObject)
         {
            if(Boolean(m_targetObject as FeatureBuilding) && ((m_targetObject as FeatureBuilding).slotmachine.canCompleteCurrentLevel || (m_targetObject as FeatureBuilding).slotmachine.isComplete))
            {
               (m_targetObject as FeatureBuilding).slotmachine.displayWindow();
            }
            else
            {
               TransactionManager.addTransaction(new TUseCSlotMachineToken(consumable,m_targetObject.getId(),m_isGift,"",false,false),true);
            }
            Global.world.popGameMode();
            Global.world.setDefaultGameMode();
         }
         else if(Global.player.getGiftCountForItem(buildingName) > 0)
         {
            Global.world.enterForcePlaceMode(buildingName);
         }
         else
         {
            UI.displayMiniMarketDialog([buildingName],"unknown","building");
         }
      }
      
      public function getBuildingName() : String
      {
         return "wishingwell";
      }
      
      public function setTargetObject() : void
      {
         var slotmachineObjects:Array = Global.world.getObjectsByName(this.getBuildingName());
         if(slotmachineObjects[0] != null && Boolean(slotmachineObjects[0] as MapResource))
         {
            m_targetObject = slotmachineObjects[0] as MapResource;
         }
      }
   }
}

