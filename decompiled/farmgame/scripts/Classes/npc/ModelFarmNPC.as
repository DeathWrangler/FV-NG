package Classes.npc
{
   import Classes.NPC;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import gs.TweenLite;
   
   public class ModelFarmNPC extends NPC
   {
      
      protected static var m_dialog:FarmDynamicDialog;
      
      private const REWARD_FEED_ICON:String = "assets/newsfeed/modelFarm_feed.png";
      
      public function ModelFarmNPC(npcid:String, NPCname:String, npcConfigData:Object)
      {
         super(npcid,npcConfigData);
         name = NPCname;
         this.hideHarvestArrowIcons();
      }
      
      override public function beginVisitAction(aid:int = -1) : void
      {
         var tagImageUrl:String;
         super.beginVisitAction(aid);
         this.hideHarvestArrowIcons();
         tagImageUrl = this.getLETagImageUrl();
         if(tagImageUrl)
         {
            Global.world.attachTagsToItems(tagImageUrl,function(item:FarmItem):Boolean
            {
               return item.isLimitedItem() && item.buyableFromModelFarm;
            },true);
         }
         onActionSuccess(this.m_actionsAvailable.shift(),this.recieveReward);
         m_actionsAvailable.pop();
      }
      
      override public function addAction(aid:int) : void
      {
      }
      
      private function hideHarvestArrowIcons() : void
      {
         var obj:SimpleHarvestableResource = null;
         var allObjects:Array = Global.world.getObjectsByType();
         for(var i:int = 0; i < allObjects.length; i++)
         {
            obj = allObjects[i] as SimpleHarvestableResource;
            if(obj != null)
            {
               obj.hideArrowDisplay();
            }
         }
      }
      
      public function getLETagImageUrl() : String
      {
         var image:Object = null;
         var url:String = null;
         for each(image in m_npcConfig.images.image)
         {
            if(Boolean(image["@attributes"]) && image["@attributes"]["name"] == "letag")
            {
               url = image["@attributes"]["url"];
               break;
            }
         }
         if(!url)
         {
            if(Boolean(m_npcConfig.images.image) && Boolean(m_npcConfig.images.image["@attributes"]) && m_npcConfig.images.image["@attributes"]["name"] == "letag")
            {
               url = m_npcConfig.images.image["@attributes"]["url"];
            }
         }
         return url;
      }
      
      public function recieveReward(result:Object) : void
      {
         var giftItem:String = null;
         if(result.rewardData)
         {
            m_rewardData = result.rewardData;
         }
         if(m_rewardData != null && m_rewardData.length > 0)
         {
            for each(giftItem in m_rewardData)
            {
               Global.player.addGift(giftItem);
            }
            this.showVisitRewardDialog();
         }
      }
      
      public function showVisitRewardDialog(delayPopSec:Number = 3) : void
      {
         if(m_rewardData != null && m_rewardData.length > 0)
         {
            TweenLite.to(this,delayPopSec,{"onComplete":function():void
            {
               var item:* = Global.farmGameSettingsManager.getFarmItemByName(m_rewardData[m_rewardData.length - 1]);
               var title:* = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_VisitReward_title");
               var message:* = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_VisitReward_body",{"item":ZLocUtils.tk_pk(item.friendlyName)});
               var rewardImage:* = item.icon;
               m_dialog = UI.showMessage(message,UI.BUTTON_LAYOUT_SHARE,title,rewardImage,true,onVisitRewardDialogClose,"feed_model_farm_reward");
            }});
         }
      }
      
      public function onVisitRewardDialogClose(isAccept:Boolean) : void
      {
         var rewardLink:String = null;
         var bundleData:Object = null;
         if(isAccept)
         {
            rewardLink = "index.php?visitNPCId=" + this.m_npcData.id;
            bundleData = {
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":Global.getAssetURL(this.REWARD_FEED_ICON)
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("ModelFarmNPC_RecievedVisitReward",bundleData,[],false);
         }
         if(m_dialog)
         {
            m_dialog.destroy();
         }
      }
   }
}

