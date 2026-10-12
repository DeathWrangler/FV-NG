package Transactions
{
   import Classes.MapResource;
   import Classes.Player;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemData;
   import Classes.UGC.UGCItemState;
   import Classes.UGC.UGCUtil;
   import Managers.ToasterManager;
   import Managers.UGCDecoManager;
   import Widgets.Windows.UGCDecorationToasterWindow;
   
   public class TCreateUGCDecoration extends TFarmTransaction
   {
      
      private var m_clientUGCItemState:UGCItemState;
      
      private var m_callback:Function;
      
      private var m_modifyUgcItem:MapResource;
      
      public function TCreateUGCDecoration(state:UGCItemState, editingUgcItem:IUGCMapResource = null, callback:Function = null)
      {
         super();
         this.m_clientUGCItemState = state;
         this.m_callback = callback;
         this.m_modifyUgcItem = editingUgcItem as MapResource;
         if(this.m_clientUGCItemState == null)
         {
            throw new Error("Attempt to created TCreateUGCItem with a null state");
         }
      }
      
      override public function perform() : void
      {
         var instanceId:Number = 0;
         if(this.m_modifyUgcItem)
         {
            instanceId = this.m_modifyUgcItem.getId();
         }
         signedCall(UGCDecoManager.UGCDECOSERVICE + "." + "purchaseUGCDecoration",this.m_clientUGCItemState.packData(),instanceId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var player:Player = null;
         var ugcItemData:UGCItemData = null;
         var stateAdded:Boolean = false;
         var toaster:UGCDecorationToasterWindow = null;
         var savedUGCItemState:UGCItemState = null;
         var existingItem:IUGCMapResource = null;
         if(result != null)
         {
            savedUGCItemState = UGCItemState.createFromServerState(result["ugcItemState"]);
            player = Global.player;
            ugcItemData = player.ugcItemData;
            if(savedUGCItemState != null && savedUGCItemState.isValid() && UGCUtil.validateUUID(savedUGCItemState.uuid))
            {
               stateAdded = ugcItemData.addUGCItemState(savedUGCItemState);
               if(stateAdded)
               {
                  player.xp += result.xpGain;
                  if(result["storageData"] != null)
                  {
                     player.refreshGiftBox(result.storageData);
                  }
                  if(result["featureData"] != null)
                  {
                     UGCDecoManager.instance.setFeatureData(result["featureData"]);
                  }
                  if(result["showToaster"])
                  {
                     toaster = new UGCDecorationToasterWindow(result["showToaster"]);
                     ToasterManager.getInstance().add(toaster);
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

