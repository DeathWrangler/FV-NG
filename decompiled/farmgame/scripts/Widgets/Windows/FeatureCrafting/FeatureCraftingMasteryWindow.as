package Widgets.Windows.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureCraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingMasteryWindow extends FarmWindow
   {
      
      private static const SOUND_URL:String = "assets/sounds/sfx_crop_mastery_02.mp3";
      
      private static const RECIPE_ICON_WIDTH:Number = 100;
      
      private static const RECIPE_ICON_HEIGHT:Number = 100;
      
      private static const REWARD_ICON_WIDTH:Number = 50;
      
      private static const REWARD_ICON_HEIGHT:Number = 50;
      
      private static const MASTERY_LEVEL_BRONZE:int = 1;
      
      private static const MASTERY_LEVEL_SILVER:int = 2;
      
      private static const MASTERY_LEVEL_GOLD:int = 3;
      
      private static const MASTERY_LEVELUP_SOUND:String = "masteryLevelUp";
      
      private var m_recipe:FeatureCraftingRecipe;
      
      private var m_level:int;
      
      private var m_checkMark:MovieClip;
      
      private var m_checkBox:FarmAnimatedButton;
      
      private var m_selected:Boolean = true;
      
      private var m_fireworkMovieClip:MovieClip = null;
      
      public function FeatureCraftingMasteryWindow(recipe:FeatureCraftingRecipe, level:int)
      {
         SoundManager.addSound(MASTERY_LEVELUP_SOUND,Global.getAssetURL(SOUND_URL),false);
         this.m_recipe = recipe;
         this.m_level = level;
         super(this.m_recipe.system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_MASTERY));
      }
      
      public static function display(recipe:FeatureCraftingRecipe, level:int) : FeatureCraftingMasteryWindow
      {
         var window:FeatureCraftingMasteryWindow = null;
         if(recipe)
         {
            window = new FeatureCraftingMasteryWindow(recipe,level);
            UI.displayPopup(window,false,"FeatureCraftingMasteryWindow",true);
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.goldTitle_tf,ZLocUtils.t("Dialogs","Congratulations")));
         addWidget(new ZwTextField(m_window.master_1_tf,ZLocUtils.t("Dialogs","MasteryTitle",{"quantity":this.m_recipe.masteryStarCount})));
         addWidget(new ZwTextField(m_window.master_2_tf,ZLocUtils.t("Dialogs","MasterySubTitle",{"item":this.m_recipe.friendlyTitle})));
         if(m_window.hasOwnProperty("master_3_tf"))
         {
            addWidget(new ZwTextField(m_window.master_3_tf,ZLocUtils.t("Dialogs","MasteryRewardShare")));
         }
         if(m_window.hasOwnProperty("checkbox_tf"))
         {
            addWidget(new ZwTextField(m_window.checkbox_tf,ZLocUtils.t("Dialogs","MasteryRewardCheckboxText")));
            this.m_checkMark = m_window.checkMark_mc as MovieClip;
            this.m_checkMark.mouseEnabled = true;
            this.m_checkMark.visible = this.m_selected = true;
            this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onCheckboxClick);
            this.m_checkBox = addWidget(new FarmAnimatedButton(m_window.checkBox_mc,this.onCheckboxClick)) as FarmAnimatedButton;
         }
         switch(this.m_recipe.masteryStarCount)
         {
            default:
            case MASTERY_LEVEL_BRONZE:
               this.m_fireworkMovieClip = m_window.bronze_mc;
               break;
            case MASTERY_LEVEL_SILVER:
               this.m_fireworkMovieClip = m_window.silver_mc;
               break;
            case MASTERY_LEVEL_GOLD:
               this.m_fireworkMovieClip = m_window.gold_mc;
         }
         if(this.m_fireworkMovieClip)
         {
            this.m_fireworkMovieClip.gotoAndStop(1);
            addWidget(new ZwFrame(this.m_fireworkMovieClip));
         }
         addWidget(new FarmIcon(m_window.icon_mc,this.m_recipe.iconUrl));
         var coinIcon:FarmIcon = addWidget(new FarmIcon(m_window.icon1_mc,"assets/decorations/fv_coin_icon.png")) as FarmIcon;
         coinIcon.setIconSize(REWARD_ICON_WIDTH,REWARD_ICON_HEIGHT);
         addWidget(new ZwTextField(m_window.prize1_tf,ZLocUtils.t("Dialogs","MasteryRewardPrize",{"quantity":100})));
         var xpIcon:FarmIcon = addWidget(new FarmIcon(m_window.icon2_mc,"assets/decorations/fv_xp_icon.png")) as FarmIcon;
         xpIcon.setIconSize(REWARD_ICON_WIDTH,REWARD_ICON_HEIGHT);
         addWidget(new ZwTextField(m_window.prize2_tf,ZLocUtils.t("Dialogs","MasteryRewardPrize",{"quantity":100})));
         var starsFrame:ZwFrame = new ZwFrame(m_window.stars_mc);
         addWidget(starsFrame);
         (m_window.stars_mc as MovieClip).gotoAndStop(this.m_recipe.masteryStarCount);
         starsFrame.visible = true;
         addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","Share"),this.onAcceptButtonClick));
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         SoundManager.playSound(MASTERY_LEVELUP_SOUND);
         if(this.m_fireworkMovieClip)
         {
            this.m_fireworkMovieClip.play();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      private function getFeedImage() : String
      {
         var starImage:String = "";
         switch(this.m_recipe.masteryStarCount)
         {
            case MASTERY_LEVEL_BRONZE:
               starImage = "crop_mastery01_cb.png";
               break;
            case MASTERY_LEVEL_SILVER:
               starImage = "crop_mastery02_cb.png";
               break;
            case MASTERY_LEVEL_GOLD:
               starImage = "crop_mastery03_cb.png";
         }
         return starImage;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function onCheckboxClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = this.m_selected = !this.m_selected;
      }
      
      private function transactionCallback(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData);
         }
      }
      
      public function onAcceptButtonClick(event:MouseEvent) : void
      {
         var params:Array = null;
         if(this.selected)
         {
            params = [this.m_recipe.system.name,this.m_recipe.name,this.m_level];
            TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"postMasteryFeed",this.transactionCallback,params),true);
         }
         this.close();
      }
   }
}

