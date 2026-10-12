package Classes
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericPopupTitle;
   import Display.PottingShedWithdrawal;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class HarvestStorageBuilding extends StorageBuilding
   {
      
      protected var m_placeResult:Object = null;
      
      public function HarvestStorageBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         var result:Boolean = false;
         if(!isMouseOver)
         {
            result = super.canTakeItem(item,isMouseOver);
         }
         return result;
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = false, force:Boolean = false) : Boolean
      {
         var decoration:Decoration = resource as Decoration;
         setDisplayForState(STATE_BARE,null);
         setDisplayForState(STATE_RIPE,null);
         return super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new PottingShedWithdrawal(this));
      }
      
      override protected function updateToolTipText() : void
      {
         var storedItemName:String = null;
         var toolTip:String = null;
         if(isHighlighted() && Global.worldManager.isVisiting() == false)
         {
            switch(state)
            {
               case STATE_BUILT:
                  storedItemName = ZLocUtils.t("FarmGame",m_item.name + "Tooltip");
                  toolTip = ZLocUtils.t("FarmGame","HarvestStorageBuildingTooltip",{
                     "item":ZLocUtils.tk_pk(m_item.friendlyName),
                     "quantity":m_count,
                     "maximum":m_capacity,
                     "tooltipStr":storedItemName
                  });
                  break;
               default:
                  toolTip = m_item.friendlyTitle;
            }
         }
         else if(isHighlighted() && Global.worldManager.isVisiting() == true)
         {
            toolTip = m_item.friendlyTitle;
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function isHarvestable() : Boolean
      {
         return false;
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         var dialog:GenericPopupTitle = null;
         super.onBuildComplete(result);
         this.m_placeResult = result;
         if(result.rewardLink != null && Global.player.canShowHarvestBuildingFeed(m_item.name))
         {
            dialog = new GenericPopupTitle("PromptHarvestStorageFeedTitle_" + m_item.name,"PromptHarvestStorageFeedBody_" + m_item.name,false,GenericPopup.TYPE_ACCEPTCANCEL,this.onCloseHarvestStoragePrompt);
            dialog.setAcceptTextName("ShareHarvest");
            UI.displayPopup(dialog,true,"buyPottingShedPopup3",true);
         }
         else
         {
            Global.player.setCanShowHarvestBuildingFeed(m_item.name,true);
         }
      }
      
      override protected function setNumImageStates() : void
      {
         m_numImageStates = 1;
      }
      
      protected function onCloseHarvestStoragePrompt(event:GenericPopupEvent) : void
      {
         var buildingName:String = null;
         var feedBundleName:String = null;
         var imageUrl:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.YES)
         {
            buildingName = m_item.name.replace("_cash","");
            feedBundleName = "BuyHarvestStorage_" + buildingName;
            imageUrl = Global.farmGameSettingsManager.getString("buyHarvestStorageFeedImage_" + buildingName);
            bundleData = {
               "reward_link":this.m_placeResult.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_placeResult.rewardLink,
                  "src":Global.getAssetURL(imageUrl)
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory(feedBundleName,bundleData,[],false);
            FarmStatsManager.count("harvestStorage",m_item.name,"gift_from_buy_building","click_accept");
         }
         else
         {
            FarmStatsManager.count("harvestStorage",m_item.name,"gift_from_buy_building","click_cancel");
         }
      }
      
      override public function showStorageFullDialog() : void
      {
      }
   }
}

