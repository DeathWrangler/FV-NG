package Widgets.Frames.Breeding
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MutableAnimalEggRewardFrame extends ZwFrame
   {
      
      private var m_parentWindow:FarmWindow;
      
      private var m_itemCode:String;
      
      private var m_rewardLink:String;
      
      private var m_feedAction:String;
      
      public function MutableAnimalEggRewardFrame(element:DisplayObject, itemCode:String, parentWindow:FarmWindow, rewardLink:String, feedAction:String)
      {
         super(element);
         this.m_itemCode = itemCode;
         this.m_parentWindow = parentWindow;
         this.m_rewardLink = rewardLink;
         this.m_feedAction = feedAction + "FullyBuilt";
         addWidget(new ZwTextField(m_element.generic0_tf,ZLocUtils.t("Dialogs","AviaryEggThankShareText")));
         addWidget(new FarmAnimatedTextButton(m_element.share_bt,ZLocUtils.t("Dialogs","GenericShareButton"),this.shareReward));
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         var sizeFactor:Number = 10 / (farmItem.sizeX + farmItem.sizeY);
         addWidget(new ObjectPreviewFrame(m_element.loader_mc,farmItem,null,[sizeFactor]));
      }
      
      private function shareReward(event:Event) : void
      {
         FarmStatsManager.count("dialog","egg_complete","Share");
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         var iconURL:String = Global.getAssetURL(item.icon);
         var bundleData:Object = {
            "first_name":Global.player.firstName,
            "reward_link":this.m_rewardLink,
            "finishedReward":item.friendlyName,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_rewardLink,
               "src":item.icon
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,bundleData,[],false);
         this.m_parentWindow.close();
      }
   }
}

