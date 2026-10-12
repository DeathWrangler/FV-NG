package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LightningDealsCongratsWindow extends FarmWindow
   {
      
      private var m_bundleIndex:int = 0;
      
      private var m_itemFriendlyName:String;
      
      private var m_itemName:String;
      
      public function LightningDealsCongratsWindow(assetPath:String, bundleIndex:int, itemFriendlyName:String, itemName:String)
      {
         super(assetPath,true,true);
         this.m_bundleIndex = bundleIndex;
         this.m_itemFriendlyName = itemFriendlyName;
         this.m_itemName = itemName;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"lightning_deals_reward_title")));
         addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"lightning_deals_reward_subtitle",{"itemFriendlyName":this.m_itemFriendlyName})));
         addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"lightning_deals_share_title",{"itemFriendlyName":this.m_itemFriendlyName})));
         (m_window["icon_mc"] as MovieClip).gotoAndStop(this.m_bundleIndex);
         (m_window["icon_mc"] as MovieClip).visible = true;
         addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.shareCallback));
      }
      
      private function shareCallback(e:Event) : void
      {
         var fi:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":fi.icon
            }],
            "first_name":Global.player.firstName,
            "item":fi.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("lightning_deals_share_Reward",bundleData,[],false,null);
         close();
      }
   }
}

