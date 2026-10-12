package Widgets.Windows.Doghouse
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class DoghouseFetchResultsWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_building:FeatureBuilding;
      
      private var m_result:Object;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      public function DoghouseFetchResultsWindow(building:FeatureBuilding, result:Object)
      {
         this.m_building = building;
         this.m_result = result;
         super("assets/dialogs/FV_MyDoghouseAward.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var icon:FarmIcon = null;
         var message:String = null;
         super.postLoadComplete();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_result["lootItem"]);
         if(item)
         {
            icon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
            icon.setIconSize(ICON_SIZE,ICON_SIZE);
            icon.loadIcon(item.iconUrl);
            message = ZLocUtils.t("Dialogs","DoghouseFetch_Message",{"item":ZLocUtils.tk_pk(item.friendlyName)});
            addWidget(new ZwTextField(m_window.fetchAward_tf,message));
            if(Boolean(this.m_result["rewardItem"]) && Boolean(this.m_result["rewardLink"]))
            {
               this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("FarmGame","Share"),this.onShareButtonClick)) as FarmAnimatedTextButton;
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_result = null;
         super.release();
      }
      
      private function onShareButtonClick(event:MouseEvent) : void
      {
         var lootItem:FarmItem = null;
         var rewardLink:String = null;
         var rewardItem:FarmItem = null;
         var bundleData:Object = null;
         if(this.m_shareButton.enabled)
         {
            this.m_shareButton.enabled = false;
            lootItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_result["lootItem"]);
            if(lootItem)
            {
               if(Boolean(this.m_result["rewardItem"]) && Boolean(this.m_result["rewardLink"]))
               {
                  rewardLink = this.m_result["rewardLink"];
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_result["rewardItem"]);
                  if(rewardItem)
                  {
                     bundleData = {};
                     bundleData["reward_link"] = rewardLink;
                     bundleData["images"] = [{
                        "href":"{SN_APP_URL}" + rewardLink,
                        "src":rewardItem.iconUrl
                     }];
                     bundleData["creative"] = this.m_building.getItemName();
                     bundleData["buildingName"] = this.m_building.getItem().friendlyTitle;
                     bundleData["lootItemName"] = lootItem.friendlyTitle;
                     bundleData["rewardItemName"] = rewardItem.friendlyTitle;
                     GlobalEngine.socialNetwork.publishFeedStory("DoghouseFetchReward",bundleData,[],false);
                  }
               }
            }
            close();
         }
      }
   }
}

