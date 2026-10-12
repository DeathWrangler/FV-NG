package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.MapResource;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemState;
   import Classes.UGC.UGCUtil;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Events.FarmGameWorldEvent;
   import GameMode.GMDefault;
   import GameMode.GMSalvage;
   import Managers.UGCDecoManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.UGC.UGCDecoConfirmDeleteFrame;
   import Widgets.Frames.UGC.UGCDecoItemEditorFrame;
   import Widgets.Frames.UGC.UGCDecoSalvageFrame;
   import Widgets.Frames.UGC.UGCDecorationHUDFrame;
   import Widgets.Frames.UGC.UGCItemPaintingFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class UGCDecoWindow extends FarmWindow
   {
      
      private static const ASSET_PREVIEW_ZOOM_LEVEL:Array = [1.5];
      
      public static var ztrack:Function = ZCacheUtil.applyPartial(StatsManager.count,null,[UGCConstants.STATS_COUNTER,UGCConstants.STATS_KINGDOM_CREATE_DECO]);
      
      private var m_editor:UGCDecoItemEditorFrame;
      
      private var m_assetPreviewFrame:UGCItemPaintingFrame;
      
      private var m_hudFrame:UGCDecorationHUDFrame;
      
      private var m_customizeItem:IUGCMapResource = null;
      
      private var m_ugcItem:IUGCItem;
      
      private var m_recyclePanel:ZwFrame;
      
      private var m_confirmDeletePanel:UGCDecoConfirmDeleteFrame;
      
      private var m_tutorial:MovieClip;
      
      protected var m_accept:FarmAnimatedButton = null;
      
      private var m_gameSettingsFeatureName:String = null;
      
      public function UGCDecoWindow(ugcItem:IUGCItem = null, customizeItem:IUGCMapResource = null, gameSettingsFeatureName:String = null)
      {
         var ugcItemName:String = null;
         if(gameSettingsFeatureName == null)
         {
            gameSettingsFeatureName = UGCDecoManager.DEFAULT_FEATURE_NAME;
         }
         this.m_gameSettingsFeatureName = gameSettingsFeatureName;
         if(Boolean(ugcItem) && ugcItem.farmItem.diagnoseFailedPurchasePrereqs() == null)
         {
            this.m_ugcItem = ugcItem;
         }
         else
         {
            ugcItemName = UGCDecoManager.instance.getLastEditedBlueprint(gameSettingsFeatureName);
            this.m_ugcItem = Global.farmGameSettingsManager.getFarmItemByName(ugcItemName) as IUGCItem;
            if(this.m_ugcItem == null)
            {
               ugcItemName = UGCDecoManager.instance.getDefaultBlueprint(gameSettingsFeatureName);
               this.m_ugcItem = Global.farmGameSettingsManager.getFarmItemByName(ugcItemName) as IUGCItem;
            }
         }
         this.m_customizeItem = customizeItem;
         var ugcItemDefinition:UGCItemDefinition = Global.farmGameSettingsManager.getUGCItemDefinition(this.m_ugcItem.ugcItemName);
         super(ugcItemDefinition.editorConfig.dialogPath);
      }
      
      private static function howDoesThisWorkCloseCallback() : void
      {
         ztrack(UGCConstants.STATS_PHYLUM_WHATSTHIS,UGCConstants.STATS_CLASS_CLOSE);
      }
      
      public function get gameSettingsFeatureName() : String
      {
         return this.m_gameSettingsFeatureName;
      }
      
      override protected function postLoadComplete() : void
      {
         try
         {
            if(Global.player.postInitFinished)
            {
               this.initWindow();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferInit);
            }
         }
         catch(error:Error)
         {
            GlobalEngine.error("UGCDecoWindow","Error: " + error.message);
            ErrorManager.addError("UGCDecoWindow Error: " + error.message);
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
         if(ObjectUtil.pathExists(m_window,"header_tf"))
         {
            addWidget(new ZwTextField(m_window.header_tf,UGCUtil.t2(this.m_gameSettingsFeatureName,"header")));
         }
         if(ObjectUtil.pathExists(m_window,"title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,UGCUtil.t2(this.m_gameSettingsFeatureName,"title")));
         }
         if(ObjectUtil.pathExists(m_window,"random_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.random_bt,ZLocUtils.t("Dialogs","Random"),this.onRandomClick));
         }
         if(ObjectUtil.pathExists(m_window,"reset_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.reset_bt,ZLocUtils.t("Dialogs","Reset"),this.onResetClick));
         }
         if(ObjectUtil.pathExists(m_window,"recycling_mc"))
         {
            this.m_recyclePanel = new UGCDecoSalvageFrame(m_window.recycling_mc,this.onRecycleClose);
            addWidget(this.m_recyclePanel,false);
         }
         if(ObjectUtil.pathExists(m_window,"whatisthis_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(ObjectUtil.pathExists(m_window,"back_mc"))
         {
            addWidget(new ZwWidget(m_window.back_mc));
         }
         this.m_tutorial = m_window.tutorial_mc as MovieClip;
         this.m_tutorial.visible = false;
         this.configureWidgets();
         this.loadSavedState();
      }
      
      public function configureWidgets() : void
      {
         if(ObjectUtil.pathExists(m_window,"asset_mc"))
         {
            this.m_assetPreviewFrame = new UGCItemPaintingFrame(m_window.asset_mc,this.m_ugcItem.farmItem,ASSET_PREVIEW_ZOOM_LEVEL);
            addWidget(this.m_assetPreviewFrame,true);
         }
         if(ObjectUtil.pathExists(m_window,"container_mc"))
         {
            this.m_editor = new UGCDecoItemEditorFrame(m_window.container_mc,this.m_assetPreviewFrame,this.m_ugcItem,this.m_customizeItem);
            this.m_editor.addEventListener(UGCConstants.EVENT_REFRESH,this.handleRefresh);
            addWidget(this.m_editor,true);
         }
         if(ObjectUtil.pathExists(m_window,"hud_mc"))
         {
            this.m_hudFrame = new UGCDecorationHUDFrame(m_window.hud_mc,this.m_ugcItem,this.m_editor,this,this.onRecycleStart);
            addWidget(this.m_hudFrame,true);
         }
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         ztrack(UGCConstants.STATS_PHYLUM_VIEW);
      }
      
      override protected function onClose(event:Event) : void
      {
         try
         {
            this.saveState();
         }
         catch(e:Error)
         {
            GlobalEngine.error("UGC","UGCItemState#saveState failed: " + e.message);
         }
         super.onClose(event);
         ztrack(UGCConstants.STATS_PHYLUM_CLOSE);
         UGCDecoManager.instance.setLastEditedBlueprint(this.m_gameSettingsFeatureName,this.m_ugcItem.ugcItemName);
      }
      
      private function setVisibilityOfEditor(visible:Boolean) : void
      {
         var o:* = undefined;
         var displays:Array = [m_closeButton,m_window.header_tf,m_window.title_tf,m_window.whatisthis_mc,m_window.container_mc,m_window.random_bt,m_window.reset_bt,m_window.back_mc,this.m_assetPreviewFrame,this.m_editor,this.m_hudFrame];
         for each(o in displays)
         {
            if(o != null)
            {
               o.visible = visible;
            }
         }
         this.m_hudFrame.toggleVisibility(visible);
      }
      
      private function onRecycleClose(event:Event) : void
      {
         this.setVisibilityOfEditor(true);
         this.m_recyclePanel.visible = false;
         this.m_hudFrame.refresh(null);
         Global.world.addGameMode(new GMDefault(),true);
      }
      
      private function onRecycleStart(event:Event) : void
      {
         this.toggleRecycleOn();
         this.onRecycleClose(null);
         this.toggleRecycleOn();
      }
      
      private function toggleRecycleOn() : void
      {
         this.setVisibilityOfEditor(false);
         this.m_recyclePanel.visible = true;
         Global.world.addGameMode(new GMSalvage(this.onRecycleWarning),true);
      }
      
      private function onRecycleWarning(object:MapResource, materials:Array, callback:Function = null) : void
      {
         if(!this.m_confirmDeletePanel)
         {
            this.m_confirmDeletePanel = new UGCDecoConfirmDeleteFrame(m_window.recycleWarning_mc);
            addWidget(this.m_confirmDeletePanel);
         }
         this.m_confirmDeletePanel.reloadData(object,materials,this.generateOnConfirmClose(callback));
         this.m_confirmDeletePanel.visible = true;
         (this.m_recyclePanel as UGCDecoSalvageFrame).setInputEnabled(false);
      }
      
      private function generateOnConfirmClose(callback:Function) : Function
      {
         return function(shouldDelete:Boolean):void
         {
            if(m_confirmDeletePanel)
            {
               m_confirmDeletePanel.visible = false;
            }
            callback(shouldDelete);
            (m_recyclePanel as UGCDecoSalvageFrame).setInputEnabled(true);
         };
      }
      
      private function onRandomClick(event:MouseEvent) : void
      {
         var randomizeAnimation:MovieClip = m_window["effect_random_mc"] as MovieClip;
         if(randomizeAnimation != null)
         {
            randomizeAnimation.play();
         }
         this.m_editor.randomize();
         ztrack(UGCConstants.STATS_PHYLUM_RANDOMIZE);
      }
      
      private function onResetClick(event:MouseEvent) : void
      {
         this.m_editor.reset();
         ztrack(UGCConstants.STATS_PHYLUM_RESET);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         ztrack(UGCConstants.STATS_PHYLUM_WHATSTHIS,UGCConstants.STATS_CLASS_VIEW);
         if(this.m_tutorial)
         {
            this.m_tutorial.visible = true;
            this.m_tutorial.gotoAndPlay(2);
            this.m_accept = new FarmAnimatedButton(this.m_tutorial.accept_bt,this.onAcceptTutorial) as FarmAnimatedButton;
         }
      }
      
      public function onAcceptTutorial(event:MouseEvent) : void
      {
         this.m_tutorial.visible = false;
      }
      
      private function handleRefresh(event:DynamicObjectEvent) : void
      {
         var widget:ZwWidget = null;
         var newItem:IUGCItem = event.data as IUGCItem;
         if(this.m_ugcItem != newItem)
         {
            for each(widget in [this.m_assetPreviewFrame,this.m_editor,this.m_hudFrame])
            {
               if(widget != null)
               {
                  removeWidget(widget);
               }
            }
            this.saveState();
            this.m_ugcItem = newItem;
            this.configureWidgets();
            this.loadSavedState();
         }
      }
      
      private function saveState() : void
      {
         var ugcItemState:UGCItemState = this.m_editor.ugcItemState;
         if(ugcItemState.isValid() && ugcItemState.isCustom())
         {
            Global.player.ugcItemData.addTempUGCItemState(ugcItemState);
            TransactionManager.addTransaction(new TGenericTransaction(UGCConstants.SERVICE_CLASS,UGCConstants.SERVICE_METHOD_SAVE_TEMP_STATE,null,[ugcItemState.packData()]));
         }
      }
      
      private function loadSavedState() : void
      {
         var tempState:UGCItemState = null;
         if(this.m_ugcItem)
         {
            tempState = Global.player.ugcItemData.getTempStateByItemCode(this.m_ugcItem.farmItem.code);
            if(tempState != null)
            {
               this.m_editor.ugcItemState = tempState;
               this.m_hudFrame.refresh(null);
            }
         }
      }
   }
}

