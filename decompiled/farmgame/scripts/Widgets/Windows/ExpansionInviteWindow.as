package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.Dialogs.NpcMultiSpeechBubble;
   import Display.Dialogs.NpcSpeechBubble;
   import Display.FarmDynamicDialog;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.FriendInvite.FriendInviteFrame;
   import Widgets.TextFields.FarmTextField;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.events.MouseEvent;
   
   public class ExpansionInviteWindow extends FarmWindow
   {
      
      protected static const ASSET_URL:String = "assets/dialogs/FV_England_GoldenTicket.swf";
      
      public static const EXPANSION_INVITE_FEATURE_NAME:String = "ExpansionInvite";
      
      public static const EXPANSION_INVITE_FEED_NAME:String = "expansionInvite";
      
      public static const EXPANSION_INVITE_SEEN_FLAG:String = "expInvite";
      
      private static const FEED_ICON_BASE_URL:String = "assets/newsfeed/expansions_invite_";
      
      private var m_expansionName:String = "";
      
      private var m_friendList:Array;
      
      private var m_whatIsThisButton:FarmAnimatedTextButton = null;
      
      public function ExpansionInviteWindow(friendList:Array, expansionName:String)
      {
         this.m_friendList = friendList;
         this.m_expansionName = expansionName;
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new FriendInviteFrame(m_window.guestFrame_mc,this.m_friendList,this.m_expansionName,this.getLocalPrefix(),this.onFriendInvite),true);
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.getLocalPrefix() + "Title")));
         addWidget(new FarmTextField(m_window.generic_tf,ZLocUtils.t("Dialogs",this.getLocalPrefix() + "Body")));
         this.m_whatIsThisButton = new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkCallback);
         addWidget(this.m_whatIsThisButton);
         FarmStatsManager.count("expansioninvite","prompt","prompt");
         Global.player.setSeenFlag(EXPANSION_INVITE_SEEN_FLAG);
      }
      
      private function onFriendInvite(uid:String, customMessage:String) : void
      {
         this.publishInviteW2W(uid,customMessage);
      }
      
      private function getLocalPrefix() : String
      {
         return this.m_expansionName + "_expansion_invite_";
      }
      
      private function howDoesThisWorkCallback(event:MouseEvent) : void
      {
         this.displayWhatIsThis();
         this.m_whatIsThisButton.enabled = false;
      }
      
      private function displayWhatIsThis() : void
      {
         var whatIsThis:FarmDynamicDialog = FarmDynamicDialog.createDialog("npcSpeechBubbleFull",NpcMultiSpeechBubble);
         whatIsThis.addImport(NpcSpeechBubble.LOC_BUNDLE_NAME_IMPORT,"Quests");
         whatIsThis.addImport(NpcSpeechBubble.LOC_RESOURCE_NAME_IMPORT,this.getLocalPrefix() + "whatsthis");
         whatIsThis.addImport(NpcSpeechBubble.BUTTON_TEXT_LOC_KEY_IMPORT,"englandquestmap_whatsthis_button");
         whatIsThis.addImport(NpcSpeechBubble.NPC_IMAGE_URL_IMPORT,"assets/dialogs/4d_elements/Questing/NPC_standing_duke_standard_alt.png");
         whatIsThis.addImport(NpcSpeechBubble.BUTTON_CALLBACK_IMPORT,this.onWhatIsThisClosed);
         whatIsThis.setup();
         whatIsThis.show();
         FarmStatsManager.count("expansioninvite","prompt","click_whatisthis");
      }
      
      override protected function release() : void
      {
         this.m_whatIsThisButton = null;
         super.release();
      }
      
      private function onWhatIsThisClosed(event:WidgetControllerEvent) : void
      {
         this.m_whatIsThisButton.enabled = true;
      }
      
      private function publishInviteW2W(uid:String, customMessage:String) : void
      {
         var feedBundleId:String = EXPANSION_INVITE_FEED_NAME + "0";
         var feedIconUrl:String = Global.getAssetURL(FEED_ICON_BASE_URL + "0.png");
         var params:Object = new Object();
         params.first_name = Global.player.firstName;
         params.images = [{
            "src":feedIconUrl,
            "href":"{SN_APP_URL}"
         }];
         var autoPublish:Boolean = Global.farmSocialNetwork.userHasStreamPermissions() && Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.EXPANSION_INVITE,FeatureOptionsManager.AUTO_PUBLISH_STREAM));
         GlobalEngine.socialNetwork.publishFeedStory(feedBundleId,params,[uid],false,null,0,false,autoPublish,customMessage);
      }
   }
}

