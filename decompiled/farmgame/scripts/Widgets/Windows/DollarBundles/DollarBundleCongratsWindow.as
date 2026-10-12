package Widgets.Windows.DollarBundles
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.QueuedIcon;
   import Managers.DollarBundlesManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DollarBundleCongratsWindow extends FarmWindow
   {
      
      private const ASSET_PATH:String = "assets/dialogs/FV_DollarBundles_Claim_2015.swf";
      
      private var m_itemName:String = "";
      
      private var m_smallDialog:MovieClip = new MovieClip();
      
      private var m_BulbBorder_start_mc:MovieClip = new MovieClip();
      
      private var m_Bulb:MovieClip = new MovieClip();
      
      private var m_Scene:MovieClip = new MovieClip();
      
      private var m_WelcomeTitle:MovieClip = new MovieClip();
      
      private var m_CongratsTitle:MovieClip = new MovieClip();
      
      private var m_DialogBody1Text:ZwTextField;
      
      private var m_DialogBody2Text:ZwTextField;
      
      private var m_Discount_tf:ZwTextField;
      
      protected var m_item:FarmItem = null;
      
      public function DollarBundleCongratsWindow(itemName:String)
      {
         super(this.ASSET_PATH);
         this.m_itemName = itemName;
      }
      
      override protected function postLoadComplete() : void
      {
         var maxDiscount:int = 0;
         super.postLoadComplete();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(m_window.hasOwnProperty("body_tf"))
         {
            maxDiscount = DollarBundlesManager.getInstance().getMaxDiscount();
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","dollarbundles_claimSubTitle",{
               "maxDiscount":maxDiscount,
               "itemName":this.m_item.friendlyTitle
            })));
         }
         if(m_window.hasOwnProperty("body1_tf"))
         {
            addWidget(new ZwTextField(m_window.body1_tf,ZLocUtils.t("Dialogs","dollarbundles_congratsText",{"bundleName":this.m_item.friendlyTitle})));
         }
         if(m_window.hasOwnProperty("bulbBorder_start_mc"))
         {
            this.m_BulbBorder_start_mc = m_window.bulbBorder_start_mc;
            this.m_BulbBorder_start_mc.visible = true;
            this.m_BulbBorder_start_mc.play();
         }
         if(m_window.hasOwnProperty("timer_tf"))
         {
            addWidget(new ZwTextField(m_window.timer_tf,"20 hrs left"));
         }
         if(m_window.hasOwnProperty("smallDialog_mc"))
         {
            this.m_smallDialog = m_window.smallDialog_mc;
            this.m_smallDialog.visible = true;
            if(this.m_smallDialog)
            {
               if(this.m_smallDialog.hasOwnProperty("body1_txt"))
               {
                  this.m_DialogBody1Text = new ZwTextField(this.m_smallDialog.body1_txt,ZLocUtils.t("Dialogs","dollarbundles_congratsText",{"bundleName":this.m_item.friendlyTitle}));
                  if(DollarBundlesManager.getInstance().getFeatureOptionsKey(DollarBundlesManager.BOUGHT_BUNDLE_COUNT) == DollarBundlesManager.getInstance().getBundleArrayLenth())
                  {
                     this.m_DialogBody1Text.text += "\n" + ZLocUtils.t("Dialogs","dollarbundles_finishText");
                  }
                  this.m_DialogBody1Text.visible = true;
               }
               if(this.m_smallDialog.hasOwnProperty("body2_txt"))
               {
                  this.m_DialogBody2Text = new ZwTextField(this.m_smallDialog.body2_txt,"");
                  this.m_DialogBody2Text.visible = false;
               }
               if(this.m_smallDialog.hasOwnProperty("bulbs_mc"))
               {
                  this.m_Bulb = this.m_smallDialog.bulbs_mc;
                  this.m_Bulb.visible = true;
                  this.m_Bulb.play();
               }
               if(this.m_smallDialog.hasOwnProperty("scene_mc"))
               {
                  this.m_Scene = this.m_smallDialog.scene_mc;
                  this.m_Scene.visible = true;
               }
               if(this.m_smallDialog.hasOwnProperty("titleWelcome_mc"))
               {
                  this.m_WelcomeTitle = this.m_smallDialog.titleWelcome_mc;
                  this.m_WelcomeTitle.visible = false;
               }
               if(this.m_smallDialog.hasOwnProperty("titleCongrats_mc"))
               {
                  this.m_CongratsTitle = this.m_smallDialog.titleCongrats_mc;
                  this.m_CongratsTitle.visible = true;
               }
               if(this.m_smallDialog.hasOwnProperty("accept_bt"))
               {
                  addWidget(new FarmAnimatedButton(this.m_smallDialog.accept_bt,this.onClose));
               }
               if(this.m_smallDialog.hasOwnProperty("discount_tf"))
               {
                  this.m_Discount_tf = new ZwTextField(this.m_smallDialog.discount_tf,"");
                  this.m_Discount_tf.visible = false;
               }
            }
         }
         FarmStatsManager.count("Superbundle","Action","PostbuyScreen","view","","");
      }
      
      override protected function onClose(event:Event) : void
      {
         var dollarBundleHudIcon:QueuedIcon = null;
         super.onClose(event);
         if(DollarBundlesManager.getInstance().getFeatureOptionsKey(DollarBundlesManager.BOUGHT_BUNDLE_COUNT) == DollarBundlesManager.getInstance().getBundleArrayLenth())
         {
            dollarBundleHudIcon = Global.hud.rightSideIconQueue.getIconByFeatureName(DollarBundlesManager.FEATURE_NAME);
            if(dollarBundleHudIcon)
            {
               Global.hud.rightSideIconQueue.removeIcon(dollarBundleHudIcon);
            }
            Global.hud.refreshIconVisibility();
            DollarBundlesManager.getInstance().saveFeatureOptionsKey(DollarBundlesManager.PURCHASED_ALL_BUNDLES,1);
         }
         else
         {
            DollarBundlesManager.getInstance().clearFeatureOptionsForNextBundle();
            DollarBundlesManager.getInstance().openDollarBundlesUI();
         }
      }
   }
}

