package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildConsumableSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildWelcomeWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "FVGuild";
      
      private static const WINDOW_PREFIX:String = "guild_welcome_";
      
      private var m_featureName:String = null;
      
      public const GUILD_WELCOME_SEEN_FLAG:String = "Guild_Welcome_flag";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var m_cpoints_tf:ZwTextField;
      
      private var m_create_tf:ZwTextField;
      
      private var m_create_des_tf:ZwTextField;
      
      private var m_join_tf:ZwTextField;
      
      private var m_join_des_tf:ZwTextField;
      
      private var m_consumable_mc:MovieClip;
      
      private var m_count_tf:ZwTextField;
      
      private var m_collect_tf:ZwTextField;
      
      private var m_ask_tf:ZwTextField;
      
      private var m_banner_mc:MovieClip;
      
      private var m_consumable_icon_mc:MovieClip;
      
      private var m_keyIcon:FarmIcon;
      
      private var m_consumable_tf:ZwTextField;
      
      private const COLLECTION_MC:Array = ["req0_mc","req1_mc","req2_mc"];
      
      private var m_consumableButtonArray:Array = [];
      
      private var m_join_request_tf:ZwTextField;
      
      public var m_consumableSlotFrame:GuildConsumableSlotContainerFrame;
      
      private var m_cpoints_mc:MovieClip;
      
      private var m_npcMc:MovieClip;
      
      private var m_npcTalkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_scratch_mc:MovieClip;
      
      private var m_cpointsFrame:ZwFrame;
      
      private var m_scratch_anim_mc:MovieClip;
      
      public var m_overlayMC:MovieClip;
      
      private var m_marketing1Tf:ZwTextField;
      
      private var m_marketing2Tf:ZwTextField;
      
      public var m_scratchAnimationRunning:Boolean = false;
      
      private var m_craftBt:FarmAnimatedTextButton;
      
      public function GuildWelcomeWindow(featureName:String = "FVGuild", assetUrl:String = null)
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var bannerIcon:FarmIcon = null;
         var consumableItem:FarmItem = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "title")));
         }
         if(m_window.hasOwnProperty("cpoints_mc"))
         {
            this.m_cpoints_mc = m_window["cpoints_mc"] as MovieClip;
            if(this.m_cpoints_mc)
            {
               this.m_cpoints_mc.visible = true;
               this.m_cpointsFrame = new ZwFrame(this.m_cpoints_mc);
               this.m_cpointsFrame.attachTooltip(new FarmTextTooltip("Your Stat Points"));
               if(this.m_cpoints_mc.hasOwnProperty("cpoints_tf"))
               {
                  this.m_cpoints_tf = new ZwTextField(this.m_cpoints_mc["cpoints_tf"],GuildManager.getInstance().getUserPoints().toString());
                  this.m_cpoints_tf.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("create_tf"))
         {
            this.m_create_tf = new ZwTextField(m_window["create_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "create_title"));
            this.m_create_tf.visible = true;
         }
         if(m_window.hasOwnProperty("create_des_tf"))
         {
            this.m_create_des_tf = new ZwTextField(m_window["create_des_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "create_description"));
            this.m_create_des_tf.visible = true;
         }
         if(m_window.hasOwnProperty("join_des_tf"))
         {
            this.m_join_des_tf = new ZwTextField(m_window["join_des_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "browse_description"));
            this.m_join_des_tf.visible = true;
         }
         if(m_window.hasOwnProperty("join_tf"))
         {
            this.m_join_tf = new ZwTextField(m_window["join_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "join_title"));
            this.m_join_tf.visible = true;
         }
         if(m_window.hasOwnProperty("banner_mc"))
         {
            bannerIcon = new FarmIcon(m_window["banner_mc"],Global.flashHotParams["GUILD_WELCOME_WINDOW_FEATURE_BANNER"]);
            bannerIcon.attachTooltip(new FarmTextTooltip("Coming Soon"));
            bannerIcon.visible = true;
            bannerIcon.setIconSize(250,200);
         }
         this.m_join_request_tf = new ZwTextField(m_window["join_request_tf"],"");
         this.m_join_request_tf.visible = true;
         this.m_join_request_tf.text = GuildManager.getInstance().getOtherRequestText();
         if(m_window.hasOwnProperty("scratch_bt"))
         {
            if(GuildManager.getInstance().isScratchAvailable())
            {
               addWidget(new FarmAnimatedTextButton(m_window["scratch_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "scratch_button_text"),this.onScratchCard));
               this.m_create_des_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "scratch_description");
               this.m_scratch_mc = m_window["scratch_mc"] as MovieClip;
               this.m_scratch_mc.visible = true;
            }
            else if(GuildManager.getInstance().isCreateCouponAvailable())
            {
               this.m_create_des_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "create_description");
               addWidget(new FarmAnimatedTextButton(m_window["scratch_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "create_button_text"),this.onCreateGuildWithTicketClick));
            }
            else
            {
               this.m_create_des_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "create_description");
               addWidget(new FarmAnimatedTextButton(m_window["scratch_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "create_button_text"),this.onCreateGuildWithFVCashClick));
            }
            this.m_scratch_anim_mc = m_window["scratch_anim_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("join_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["join_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "browse_button_text"),this.onJoinGuild));
         }
         if(m_window.hasOwnProperty("consumable_mc"))
         {
            this.m_consumable_mc = m_window["consumable_mc"] as MovieClip;
            this.m_consumable_mc.visible = true;
            if(this.m_consumable_mc)
            {
               consumableItem = Global.farmGameSettingsManager.getFarmItemByName("clantoken");
               this.m_keyIcon = new FarmIcon(this.m_consumable_mc["icon_mc"],consumableItem.iconUrl);
               this.m_keyIcon.attachTooltip(new FarmTextTooltip(consumableItem.friendlyTitle));
               this.m_keyIcon.setIconSize(70,70);
               this.m_keyIcon.setSmoothing(true);
               addWidget(this.m_keyIcon,true);
               this.m_count_tf = new ZwTextField(this.m_consumable_mc["count_tf"]);
               this.m_count_tf.visible = true;
               this.m_count_tf.text = GuildManager.getInstance().getKeyCount().toString();
               this.m_consumable_tf = new ZwTextField(this.m_consumable_mc["consumable_tf"]);
               this.m_consumable_tf.visible = true;
               this.m_consumable_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "key_inventory_title");
               this.m_collect_tf = new ZwTextField(this.m_consumable_mc["collect_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "key_inventory_subtitle"));
               this.m_collect_tf.visible = true;
               this.populateConsumables();
               this.m_consumable_icon_mc = this.m_consumable_mc["icon_mc"] as MovieClip;
               this.m_consumable_icon_mc.visible = true;
               addWidget(this.m_craftBt = new FarmAnimatedTextButton(this.m_consumable_mc["craft_bt"],"Craft",this.onCraftClick));
               if(GuildManager.getInstance().hasGuildKeyCapReached())
               {
                  this.m_craftBt.callback = null;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_craftBt,"Your token inventory is full");
               }
            }
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npcMc = m_window.npc_mc as MovieClip;
            this.m_npcMc.visible = false;
            this.m_npcMc.play();
            if(this.m_npcMc.hasOwnProperty("talk_mc"))
            {
               this.m_npcTalkMc = this.m_npcMc.talk_mc as MovieClip;
               this.m_npcTalkMc.visible = true;
               this.m_npc1Tf = new ZwTextField(this.m_npcTalkMc["npc1_tf"]," Auto npc1");
               this.m_npc2Tf = new ZwTextField(this.m_npcTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMC = m_window["overlay_mc"] as MovieClip;
            this.m_overlayMC.visible = false;
         }
         if(m_window.hasOwnProperty("marketing1_tf"))
         {
            this.m_marketing1Tf = new ZwTextField(m_window["marketing1_tf"],"Road to Riches");
            this.m_marketing1Tf.visible = true;
         }
         if(m_window.hasOwnProperty("marketing2_tf"))
         {
            this.m_marketing2Tf = new ZwTextField(m_window["marketing2_tf"],"Embark on an adventure of a lifetime!");
            this.m_marketing2Tf.visible = true;
         }
         if(!Global.player.getSeenFlag(GuildManager.GUILD_IGNORE_COUPON))
         {
            this.showNPCCallouts("Let’s Play Together!","Hello & Welcome to our first ever Farmers Clan, a place where you can farm, chat and win with friends!");
            this.m_cpoints_mc.visible = false;
         }
      }
      
      private function populateConsumables() : void
      {
         this.m_consumableSlotFrame = new GuildConsumableSlotContainerFrame(this.m_consumable_mc["reqs_mc"],this.m_featureName) as GuildConsumableSlotContainerFrame;
         this.m_consumableSlotFrame.visible = true;
      }
      
      private function onCraftClick(e:Event) : void
      {
         GuildManager.getInstance().openConsumableCraftWindow();
      }
      
      private function onScratchCard(e:Event) : void
      {
         GuildManager.getInstance().tryScratchCard();
         this.m_scratch_anim_mc.visible = true;
         this.m_scratchAnimationRunning = true;
         this.m_scratch_anim_mc.play();
         this.m_scratch_anim_mc.addEventListener(Event.ENTER_FRAME,this.onActiveNPCAnimationComplete(this.m_scratch_anim_mc));
      }
      
      private function onActiveNPCAnimationComplete(scratch_anim_mc:MovieClip) : Function
      {
         return function(event:Event):void
         {
            if(scratch_anim_mc.currentFrame == 140)
            {
               scratch_anim_mc.stop();
               m_scratchAnimationRunning = false;
               scratch_anim_mc.removeEventListener(Event.ENTER_FRAME,onActiveNPCAnimationComplete(scratch_anim_mc));
            }
         };
      }
      
      public function hideScratchAnimation() : void
      {
         this.m_scratch_anim_mc.visible = false;
      }
      
      private function onCreateGuildWithTicketClick(e:Event) : void
      {
         GuildManager.getInstance().openCreateGuildWithTicket();
      }
      
      private function onCreateGuildWithFVCashClick(e:Event) : void
      {
         GuildManager.getInstance().openCreateGuildWithFVCash();
      }
      
      private function onJoinGuild(e:Event) : void
      {
         GuildManager.getInstance().openGuildListWindow();
      }
      
      private function onCollect(slotIndex:int) : Function
      {
         return function(e:Event):void
         {
            GuildManager.getInstance().collectConsumable(slotIndex);
         };
      }
      
      public function refreshKeyCount() : void
      {
         if(this.m_count_tf)
         {
            this.m_count_tf.text = GuildManager.getInstance().getKeyCount().toString();
            this.m_count_tf.visible = true;
         }
         if(GuildManager.getInstance().hasGuildKeyCapReached())
         {
            if(GuildManager.getInstance().m_guildConsumableCraftWindow)
            {
               GuildManager.getInstance().m_guildConsumableCraftWindow.refreshGuildCraftWindow();
            }
            this.m_craftBt.callback = null;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_craftBt,"Your token inventory is full");
         }
         else
         {
            if(this.m_craftBt.tooltip)
            {
               this.m_craftBt.detachTooltip();
            }
            this.m_craftBt.callback = null;
            this.m_craftBt.callback = this.onCraftClick;
            this.m_craftBt.enabled = true;
         }
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_npcMc.visible = true;
      }
      
      override public function close() : void
      {
         GuildManager.getInstance().m_welcomeWindow = null;
         super.close();
      }
   }
}

