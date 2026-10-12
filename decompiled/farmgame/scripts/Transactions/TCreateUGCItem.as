package Transactions
{
   import Classes.MapResource;
   import Classes.Player;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemData;
   import Classes.UGC.UGCItemState;
   import Classes.UGC.UGCUtil;
   
   public class TCreateUGCItem extends TFarmTransaction
   {
      
      private var m_clientUGCItemState:UGCItemState;
      
      private var m_callback:Function;
      
      private var m_totalCash:int;
      
      private var m_modifyUgcItem:MapResource;
      
      public function TCreateUGCItem(state:UGCItemState, totalCash:int = 0, editingUgcItem:IUGCMapResource = null, callback:Function = null)
      {
         super();
         this.m_clientUGCItemState = state;
         this.m_totalCash = totalCash;
         this.m_callback = callback;
         this.m_modifyUgcItem = editingUgcItem as MapResource;
         if(this.m_clientUGCItemState == null)
         {
            throw new Error("Attempt to created TCreateUGCItem with a null state");
         }
      }
      
      public function get isCustomizing() : Boolean
      {
         return this.m_modifyUgcItem != null;
      }
      
      override public function perform() : void
      {
         var instanceId:Number = 0;
         if(this.m_modifyUgcItem)
         {
            instanceId = this.m_modifyUgcItem.getId();
         }
         signedCall(UGCConstants.SERVICE_CLASS + "." + UGCConstants.SERVICE_METHOD_CREATE_STATE,this.m_clientUGCItemState.packData(),instanceId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var player:Player = null;
         var ugcItemData:UGCItemData = null;
         var stateAdded:Boolean = false;
         var savedUGCItemState:UGCItemState = null;
         var existingItem:IUGCMapResource = null;
         if(result != null)
         {
            if(Boolean(result["existingItemId"]) && result["existingItemId"] > 0)
            {
               existingItem = Global.world.getObjectById(result["existingItemId"] as int) as IUGCMapResource;
            }
            savedUGCItemState = UGCItemState.createFromServerState(result["ugcItemState"]);
            player = Global.player;
            ugcItemData = player.ugcItemData;
            if(savedUGCItemState != null && savedUGCItemState.isValid() && UGCUtil.validateUUID(savedUGCItemState.uuid))
            {
               stateAdded = ugcItemData.addUGCItemState(savedUGCItemState);
               if(stateAdded)
               {
                  player.cash -= this.m_totalCash;
                  player.xp += result.xpGain;
                  if(result["storageData"] != null)
                  {
                     player.refreshGiftBox(result.storageData);
                  }
                  ugcItemData.removeTempUGCItemState(savedUGCItemState.itemCode);
               }
               else
               {
                  GlobalEngine.error("UGC","TCreateUGCItem#onComplete failed to add state to UGC data");
               }
            }
            else
            {
               GlobalEngine.error("UGC","TCreateUGCItem#onComplete failed to create state from UGC state response");
            }
         }
         else
         {
            GlobalEngine.error("UGC",UGCConstants.SERVICE_CLASS + "." + UGCConstants.SERVICE_METHOD_CREATE_STATE + " failed to create UGC item from state");
         }
         if(this.m_callback != null)
         {
            this.m_callback(savedUGCItemState,existingItem);
         }
      }
   }
}

