package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Events.FarmGameWorldEvent;
   import Managers.CaptureFeatureManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CaptureFeatureBuilding.CaptureFeatureBuildingFrame;
   import Widgets.Frames.CaptureFeatureBuilding.FeatureItemFrame;
   import flash.events.Event;
   
   public class CaptureFeatureWindow extends FarmWindow
   {
      
      private var m_building:FeatureBuilding = null;
      
      private var m_title:ZwTextField = null;
      
      private var m_description:ZwTextField = null;
      
      private var m_howDoesThisWork_bt:FarmAnimatedTextButton = null;
      
      private var m_itemsTab_bt:FarmAnimatedTextButton = null;
      
      private var m_buildingTab_bt:FarmAnimatedTextButton = null;
      
      private var m_itemFrame:FeatureItemFrame = null;
      
      private var m_treatFrame:ZwFrame = null;
      
      private var m_buildingFrame:CaptureFeatureBuildingFrame = null;
      
      private var m_featureName:String = null;
      
      public function CaptureFeatureWindow(building:FeatureBuilding)
      {
         this.m_building = building;
         this.m_featureName = building.getItemName();
         var dialogConfig:Object = Global.farmGameSettingsManager.getBuildingDialogConfig(this.m_featureName);
         if(dialogConfig != null && dialogConfig.path != "")
         {
            super(dialogConfig.path);
            return;
         }
         throw new Error("Dialog path for capture feature building not found: " + this.m_featureName);
      }
      
      override protected function postLoadComplete() : void
      {
         FarmStatsManager.count("dialog",this.getStatName("_dialog"),"ui","","view");
         if(Global.player.postInitFinished)
         {
            this.initWindow();
         }
         else
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferInit);
         }
      }
      
      private function deferInit(event:Event) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferInit);
         this.initWindow();
      }
      
      private function initWindow() : void
      {
         super.postLoadComplete();
         var prefix:String = CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName);
         this.m_title = addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",prefix + "_Title"))) as ZwTextField;
         this.m_description = addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs",prefix + "_Description"))) as ZwTextField;
         this.m_howDoesThisWork_bt = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick)) as FarmAnimatedTextButton;
         this.m_itemsTab_bt = addWidget(new FarmAnimatedTextButton(m_window.gopherTab_mc,ZLocUtils.t("Dialogs",prefix + "_GopherTab"),this.showGopherFrame)) as FarmAnimatedTextButton;
         this.m_buildingTab_bt = addWidget(new FarmAnimatedTextButton(m_window.progressTab_mc,ZLocUtils.t("Dialogs",prefix + "_ProgressTab"),this.showBuildingFrame)) as FarmAnimatedTextButton;
         if(m_window.strings_mc)
         {
            addWidget(new ZwBaseWidget(m_window.strings_mc));
         }
         this.initItemFrame();
         this.initBuildingFrame();
         this.initTreatFrame();
         this.m_itemFrame.visible = true;
         this.m_buildingFrame.visible = false;
         this.m_buildingTab_bt.visible = true;
      }
      
      private function initItemFrame() : void
      {
         var featureItems:Array = CaptureFeatureManager.instance.getFeatureItems(this.m_featureName);
         var captureCount:int = CaptureFeatureManager.instance.getCapturedCount(this.m_featureName);
         var buildingLevel:int = CaptureFeatureManager.instance.getCurrentBuildLevel(this.m_featureName);
         this.m_itemFrame = addWidget(new FeatureItemFrame(this.m_featureName,m_window.gophers_mc,featureItems,captureCount,buildingLevel),false) as FeatureItemFrame;
      }
      
      private function initTreatFrame() : void
      {
         this.m_treatFrame = addWidget(new ZwFrame(m_window.treats_mc),true) as ZwFrame;
         this.m_treatFrame.addWidget(new ZwTextField(this.m_treatFrame.element.treatCount_tf));
         this.m_treatFrame.addWidget(new ZwBaseWidget(this.m_treatFrame.element.treat_mc));
         var treatPrice:int = CaptureFeatureManager.instance.getTreatPrice(this.m_featureName);
         this.m_treatFrame.addWidget(new FarmAnimatedTextButton(this.m_treatFrame.element.buy_mc,ZLocUtils.t("Dialogs",this.getStringKey("_BuyTreat")),this.buyTreatCallback));
         if(this.m_treatFrame.element.buy_mc.cost_tf)
         {
            this.m_treatFrame.element.buy_mc.cost_tf.text = treatPrice.toString();
         }
         this.m_treatFrame.addWidget(new FarmAnimatedTextButton(this.m_treatFrame.element.askFor_mc,ZLocUtils.t("Dialogs",this.getStringKey("_TreatAsk")),this.askForTreatsCallback));
         this.updateTreatFrame();
      }
      
      private function buyTreatCallback(event:Event) : void
      {
         FarmStatsManager.count("dialog",this.getStatName("_dialog"),"ui","","buy_treat");
         CaptureFeatureManager.instance.purchaseGopherTreat(this.m_featureName,this.buyTreatTransactionCallback);
         var widget:ZwBaseWidget = this.m_treatFrame.getWidget("buy_mc");
         if(widget)
         {
            widget.enabled = false;
         }
      }
      
      private function buyTreatTransactionCallback(data:Object) : void
      {
         if(data.hasOwnProperty("success"))
         {
            Global.player.cash -= CaptureFeatureManager.instance.getTreatPrice(this.m_featureName);
         }
         this.updateTreatFrame();
      }
      
      private function askForTreatsCallback(event:Event) : void
      {
         var widget:FarmAnimatedTextButton = null;
         if(CaptureFeatureManager.instance.canAskForTreats(this.m_featureName,CaptureFeatureManager.SOURCE_UI))
         {
            widget = this.m_treatFrame.getWidget("askFor_mc") as FarmAnimatedTextButton;
            if(widget)
            {
               widget.enabled = false;
               widget.text = ZLocUtils.t("Dialogs",this.getStringKey("_TreatPosting"));
            }
            FarmStatsManager.count("dialog",this.getStatName("_dialog"),"ui","","ask_treat");
            CaptureFeatureManager.instance.askForTreats(this.m_featureName,CaptureFeatureManager.SOURCE_UI,this.postFeedCallback);
         }
      }
      
      private function postFeedCallback(data:Object) : void
      {
         this.updateTreatFrame();
      }
      
      private function updateTreatFrame() : void
      {
         var maxTreats:int = 0;
         var treatCount:int = 0;
         var widget:ZwBaseWidget = null;
         var treatCounttf:ZwTextField = null;
         var askButtonText:String = null;
         var secondsToNextPost:int = 0;
         var isFeedLocked:Boolean = false;
         if(this.m_treatFrame)
         {
            maxTreats = CaptureFeatureManager.instance.getCurrentMaxTreats(this.m_featureName);
            treatCount = CaptureFeatureManager.instance.getTreatCount(this.m_featureName);
            widget = this.m_treatFrame.getWidget("askFor_mc");
            if(widget)
            {
               askButtonText = ZLocUtils.t("Dialogs",this.getStringKey("_TreatAsk"));
               if(CaptureFeatureManager.instance.canAskForTreats(this.m_featureName,CaptureFeatureManager.SOURCE_UI))
               {
                  widget.enabled = true;
               }
               else
               {
                  widget.enabled = false;
                  secondsToNextPost = CaptureFeatureManager.instance.secondsLeftToNextAskForTreats(this.m_featureName,CaptureFeatureManager.SOURCE_UI);
                  isFeedLocked = CaptureFeatureManager.instance.isFeedLocked(this.m_featureName,CaptureFeatureManager.SOURCE_UI);
                  if(isFeedLocked)
                  {
                     CaptureFeatureManager.instance.registerOnUnlockCallback(CaptureFeatureManager.SOURCE_UI,this.updateTreatFrame);
                     askButtonText = ZLocUtils.t("Dialogs",this.getStringKey("_TreatPosting"));
                  }
                  else if(secondsToNextPost == 0)
                  {
                     askButtonText = ZLocUtils.t("Dialogs",this.getStringKey("_TreatFull"));
                  }
                  else
                  {
                     askButtonText = ZLocUtils.t("Dialogs",this.getStringKey("_TreatAskIn"),{"time":FarmGameUtil.toFriendlyTime(secondsToNextPost,true)});
                  }
               }
               (widget as FarmAnimatedTextButton).text = askButtonText;
            }
            widget = this.m_treatFrame.getWidget("buy_mc");
            if(widget)
            {
               widget.enabled = treatCount < maxTreats;
            }
            treatCounttf = this.m_treatFrame.getWidget("treatCount_tf") as ZwTextField;
            if(treatCounttf)
            {
               treatCounttf.text = ZLocUtils.t("Dialogs",this.getStringKey("_TreatCount"),{
                  "count":treatCount,
                  "max":maxTreats
               });
            }
         }
      }
      
      private function initBuildingFrame() : void
      {
         var buildingData:Array = CaptureFeatureManager.instance.getBuildingData(this.m_featureName);
         var currentBuildingLevel:int = CaptureFeatureManager.instance.getCurrentBuildLevel(this.m_featureName);
         var captureCount:int = CaptureFeatureManager.instance.getCapturedCount(this.m_featureName);
         this.m_buildingFrame = addWidget(new CaptureFeatureBuildingFrame(this.m_featureName,m_window.upgrade_mc,buildingData,currentBuildingLevel,captureCount),false) as CaptureFeatureBuildingFrame;
      }
      
      private function showGopherFrame(event:Event) : void
      {
         this.m_itemFrame.visible = true;
         this.m_buildingFrame.visible = false;
         this.m_buildingTab_bt.visible = true;
         this.m_treatFrame.visible = true;
      }
      
      private function showBuildingFrame(event:Event) : void
      {
         this.m_itemFrame.visible = false;
         this.m_buildingFrame.visible = true;
         this.m_buildingTab_bt.visible = true;
         this.m_treatFrame.visible = false;
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.count("dialog",this.m_building.getItemName(),"what_is_this","open");
         var prefixUrl:String = this.m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(this.m_building,prefixUrl,false,this.howDoesThisWorkCloseCallback);
      }
      
      private function howDoesThisWorkCloseCallback() : void
      {
         FarmStatsManager.count("dialog",this.m_building.getItemName(),"what_is_this","close");
      }
      
      override protected function release() : void
      {
         this.m_treatFrame = null;
         super.release();
      }
      
      private function getStatName(suffix:String) : String
      {
         return CaptureFeatureManager.instance.getStatsPrefix(this.m_featureName) + suffix;
      }
      
      private function getStringKey(suffix:String) : String
      {
         return CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName) + suffix;
      }
   }
}

