package Transactions
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.LEUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   
   public class TPlace extends TWorldState
   {
      
      public static const ACTION_PLACE:String = "place";
      
      protected var m_item:FarmItem;
      
      protected var m_params:Object = {};
      
      public function TPlace(mapResource:MapResource)
      {
         this.m_item = mapResource.getItem();
         super(mapResource);
         LEUtil.handleLETransactionStart(this.m_item);
         this.m_params = new Object();
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_PLACE,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var gateCode:String = null;
         var itemXML:XML = null;
         var playerGateItem:Object = null;
         var message:GenericIconPopup = null;
         super.onComplete(result);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            gateCode = this.m_item.gateCode;
         }
         else
         {
            itemXML = Global.farmGameSettingsManager.getItemXMLByName(this.m_item.name);
            gateCode = itemXML.@gateCode.toString();
         }
         if(gateCode != "")
         {
            playerGateItem = Global.player.incrementalGateArray[gateCode];
            if(Boolean(playerGateItem) && Boolean(playerGateItem.acquired))
            {
               if(playerGateItem.acquired[this.m_item.code])
               {
                  ++playerGateItem.acquired[this.m_item.code];
               }
               else
               {
                  playerGateItem.acquired[this.m_item.code] = 1;
                  message = new GenericIconPopup(ZLocUtils.t("Dialogs","IncrementalGatePopup"),GenericPopup.TYPE_SHARECANCEL,this.onIncrementalGateClick,this.m_item.icon);
                  message.setAcceptTextName("Share");
                  UI.displayPopup(message);
               }
            }
         }
         if(m_object is MapResource)
         {
            (m_object as MapResource).onFinishPlace(result);
         }
         LEUtil.handleLETransactionComplete(result,this.m_item);
      }
      
      protected function onIncrementalGateClick(event:GenericPopupEvent) : void
      {
         var cost:String = null;
         var params:Object = null;
         var itemXML:XML = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               cost = this.m_item.cost.toString();
            }
            else
            {
               itemXML = Global.farmGameSettingsManager.getItemXMLByName(this.m_item.name);
               cost = itemXML.cost.toString();
            }
            params = {
               "actor":Global.player.name,
               "item_name":this.m_item.friendlyName,
               "coin_amount":cost,
               "images":[{
                  "src":this.m_item.icon,
                  "href":Config.SN_APP_URL
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("incrementalgate_reward",params,[],false);
            FarmStatsManager.count("viral_loot","placed_item","click_share");
         }
         else
         {
            FarmStatsManager.count("viral_loot","placed_item","click_cancel");
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_PLACE;
         result.item = this.m_item;
         result.params = this.m_params;
         return result;
      }
   }
}

