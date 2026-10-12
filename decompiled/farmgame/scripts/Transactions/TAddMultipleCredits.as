package Transactions
{
   import Classes.CreditsBuilding;
   import Classes.VirtualStorageDecoration;
   
   public class TAddMultipleCredits extends TWorldState
   {
      
      public static const ACTION_NAME:String = "addMultipleCredits";
      
      private var m_params:Object = {};
      
      private var m_building:CreditsBuilding;
      
      public function TAddMultipleCredits(building:CreditsBuilding, creditResource:VirtualStorageDecoration, creditCount:int = 1, isGift:Boolean = true)
      {
         this.m_building = building;
         this.m_params.resource = creditResource.getId();
         this.m_params.storedClassName = creditResource.getClassName();
         this.m_params.storedItemName = creditResource.getItemName();
         this.m_params.storedItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_params.storedItemName);
         this.m_params.storedItemCount = creditCount;
         this.m_params.isGift = isGift;
         if(isGift)
         {
            Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_params.storedItemName),creditCount);
         }
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_NAME,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         this.m_building.onAddMultipleCreditsComplete(result);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_NAME;
         result.storedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_params.storedItemName);
         result.item = this.m_building.getItem();
         result.resource = this.m_params.resource;
         result.cameFromLocation = this.m_params.cameFromLocation;
         return result;
      }
   }
}

