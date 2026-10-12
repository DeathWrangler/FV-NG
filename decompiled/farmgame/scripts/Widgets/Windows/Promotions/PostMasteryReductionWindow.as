package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Display.ActionMultiButton;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FreezeManager;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.setTimeout;
   
   public class PostMasteryReductionWindow extends FarmWindow
   {
      
      private static const MASTERY_REWARD_BUNDLE_ITEM_NAME:String = "consume_mastery_sign_bundle";
      
      private static const SERVICE_CLASS:String = "MasteryReductionRewardService";
      
      private static const ACTION_ADD_GIFT:String = "grantBundleReward";
      
      public static const FAQ_LINK:String = "https://support.zynga.com/article/farmville/FAQ-Mastery-Sign-Billboard-Removal-en_US-1439814929547";
      
      public static const PostMasteryReductionWindow_Seen:String = "PmrwSeen";
      
      private const ASSET_URL:String = "assets/dialogs/FV_MasteryRemoval2015_motd_launch.swf";
      
      protected var m_learnMoreLink:ZwButton;
      
      private var m_bonus_frame:ZwFrame;
      
      private var m_content:ZwFrame;
      
      public function PostMasteryReductionWindow()
      {
         super(this.ASSET_URL);
      }
      
      public static function showStatic() : void
      {
         UI.displayPopup(new PostMasteryReductionWindow());
      }
      
      override protected function postLoadComplete() : void
      {
         var content_mc:MovieClip = null;
         var bonus_mc:MovieClip = null;
         var ItemNameToolTip:ZwWidget = null;
         if(Boolean(m_window) && m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.accept_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","postMasteryReduction_MOTD_accept"),this.onAccept));
            }
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","postMasteryReduction_MOTD_title")));
            }
            if(m_window.mainWindow.body1_tf)
            {
               addWidget(new FarmTextField(m_window.mainWindow.body1_tf,ZLocUtils.t("Dialogs","postMasteryReduction_MOTD_body")),false);
            }
            if(m_window.mainWindow.content_mc)
            {
               addWidget(this.m_content = new ZwFrame(m_window.mainWindow.content_mc));
               content_mc = m_window.mainWindow.content_mc as MovieClip;
               if(content_mc.body1_tf)
               {
                  this.m_content.addWidget(new FarmTextField(content_mc.body1_tf,ZLocUtils.t("Dialogs","postMasteryReduction_MOTD_content_body_1")));
               }
               if(content_mc.body2_tf)
               {
                  this.m_content.addWidget(new FarmTextField(content_mc.body2_tf,ZLocUtils.t("Dialogs","postMasteryReduction_MOTD_content_body_2")));
               }
            }
            if(m_window.mainWindow.hasOwnProperty("knowmore_tf"))
            {
               this.m_learnMoreLink = addWidget(new ZwButton(m_window.mainWindow.knowmore_tf,this.onLernMoreLinkClick)) as ZwButton;
               this.m_learnMoreLink.visible = true;
               this.m_learnMoreLink.element.useHandCursor = true;
               this.m_learnMoreLink.element.buttonMode = true;
               this.m_learnMoreLink.element.mouseChildren = false;
            }
            if(m_window.mainWindow.bonus_mc)
            {
               bonus_mc = m_window.mainWindow.bonus_mc as MovieClip;
               addWidget(this.m_bonus_frame = new ZwFrame(m_window.mainWindow.bonus_mc));
               if(bonus_mc.hasOwnProperty("reward_tf"))
               {
                  this.m_bonus_frame.addWidget(new FarmTextField(bonus_mc.reward_tf,ZLocUtils.t("Dialogs","MasteryReduction_MOTD_rewardTitle")));
               }
               if(bonus_mc.hasOwnProperty("body_tf"))
               {
                  this.m_bonus_frame.addWidget(new FarmTextField(bonus_mc.body_tf,ZLocUtils.t("Dialogs","MasteryReduction_MOTD_rewardSubtitle")));
               }
               if(bonus_mc.hasOwnProperty("tt_mc"))
               {
                  this.m_bonus_frame.addWidget(new ZwFrame(bonus_mc.tt_mc));
               }
               ItemNameToolTip = new ZwWidget(bonus_mc);
               if(ItemNameToolTip)
               {
                  ItemNameToolTip.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","MasteryReduction_MOTD_bonus_reward_tt")));
               }
               if(this.m_learnMoreLink)
               {
                  this.m_learnMoreLink.visible = true;
               }
            }
         }
      }
      
      private function onAccept(event:MouseEvent) : void
      {
         close();
         Global.player.addGift(MASTERY_REWARD_BUNDLE_ITEM_NAME);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_ADD_GIFT,null,null));
         this.startTutorialFlow();
      }
      
      public function startTutorialFlow() : void
      {
         setTimeout(this.openActionMenu,800);
      }
      
      public function openActionMenu(arg:Array = null) : void
      {
         ToasterManager.getInstance().togglePause(true);
         FreezeManager.freezeAll(false);
         var bottomLeftActionButton:ActionMultiButton = Global.ui.getActionMenu().getBottomLeftButton();
         Global.ui.getActionMenu().setDefaultGameMode();
         if(bottomLeftActionButton)
         {
            bottomLeftActionButton.showMenu(false,true);
         }
      }
      
      private function onLernMoreLinkClick(event:Event) : void
      {
         event.stopPropagation();
         navigateToURL(new URLRequest(FAQ_LINK),"_blank");
      }
   }
}

