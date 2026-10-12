package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemState;
   import Classes.UGC.UGCUtil;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.DynamicObjectEvent;
   import Events.GenericPopupEvent;
   import Transactions.TCreateUGCItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.UGC.UGCItemEditorFrame;
   import Widgets.Frames.UGC.UGCItemPaintingFrame;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class UGCItemEditorWindow extends FarmWindow
   {
      
      private static const ASSET_PREVIEW_ZOOM_LEVEL:Array = [3];
      
      public static const STATS_PHYLUM_BUY:String = "buy";
      
      public static var ztrack:Function = ZCacheUtil.applyPartial(StatsManager.count,null,[UGCConstants.STATS_COUNTER,UGCConstants.STATS_KINGDOM_CREATE]);
      
      private var m_ugcItem:IUGCItem;
      
      private var m_priceTextField:ZwTextField;
      
      private var m_editor:UGCItemEditorFrame;
      
      private var m_customizeItem:IUGCMapResource = null;
      
      private var m_howDoesThisWork:FarmAnimatedTextButton = null;
      
      public function UGCItemEditorWindow(ugcItem:IUGCItem, customizeItem:IUGCMapResource = null, gameSettingsFeatureName:String = null)
      {
         this.m_ugcItem = ugcItem;
         this.m_customizeItem = customizeItem;
         var ugcItemDefinition:UGCItemDefinition = Global.farmGameSettingsManager.getUGCItemDefinition(this.m_ugcItem.ugcItemName);
         super(ugcItemDefinition.editorConfig.dialogPath);
      }
      
      private static function onWhatIsThisClick(event:MouseEvent) : void
      {
         var items:Array = [{
            "overview":"DreamHorseTutorial_SlotOOverview",
            "title":"DreamHorseTutorial_SlotOTitle",
            "body":"DreamHorseTutorial_SlotOBody",
            "imageUrl":"assets/dialogs/4d_elements/UGCPony/UGCPony_imgs_1.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"DreamHorseTutorial_Slot1Overview",
            "title":"DreamHorseTutorial_Slot1Title",
            "body":"DreamHorseTutorial_Slot1Body",
            "imageUrl":"assets/dialogs/4d_elements/UGCPony/UGCPony_imgs_2.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"DreamHorseTutorial_Slot2Overview",
            "title":"DreamHorseTutorial_Slot2Title",
            "body":"DreamHorseTutorial_Slot2Body",
            "imageUrl":"assets/dialogs/4d_elements/UGCPony/UGCPony_imgs_3.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"DreamHorseTutorial_Slot3Overview",
            "title":"DreamHorseTutorial_Slot3Title",
            "body":"DreamHorseTutorial_Slot3Body",
            "imageUrl":"assets/dialogs/4d_elements/UGCPony/UGCPony_imgs_4.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         TutorialUI.displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","DreamHorseTutorial_Title"),false,false,null);
      }
      
      override protected function postLoadComplete() : void
      {
         var assetPreviewFrame:UGCItemPaintingFrame = null;
         var closeWarning:ZwFrame = null;
         if(ObjectUtil.pathExists(m_window,"header_tf"))
         {
            addWidget(new ZwTextField(m_window.header_tf,UGCUtil.t(this.m_ugcItem,"header")));
         }
         if(ObjectUtil.pathExists(m_window,"title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,UGCUtil.t(this.m_ugcItem,"title")));
         }
         if(ObjectUtil.pathExists(m_window,"random_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.random_bt,ZLocUtils.t("Dialogs","Random"),this.onRandomClick));
         }
         if(ObjectUtil.pathExists(m_window,"reset_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.reset_bt,ZLocUtils.t("Dialogs","Reset"),this.onResetClick));
         }
         if(ObjectUtil.pathExists(m_window,"buy_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.buy_bt,UGCUtil.t(this.m_ugcItem,"buyButtonText"),this.onBuyClick));
         }
         if(ObjectUtil.pathExists(m_window,"cost_tf"))
         {
            this.m_priceTextField = new ZwTextField(m_window.cost_tf);
            addWidget(this.m_priceTextField,true);
         }
         if(ObjectUtil.pathExists(m_window,"whatisthis_mc"))
         {
            this.m_howDoesThisWork = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),onWhatIsThisClick)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_window,"creating_mc"))
         {
            addWidget(new ZwFrame(m_window.creating_mc),false);
         }
         if(ObjectUtil.pathExists(m_window,"closeWarning_mc"))
         {
            closeWarning = new ZwFrame(m_window.closeWarning_mc);
            if(ObjectUtil.pathExists(m_window.closeWarning_mc,"close_bt"))
            {
               closeWarning.addWidget(new FarmAnimatedTextButton(m_window.closeWarning_mc.close_bt,ZLocUtils.t("Dialogs","Close"),this.onCloseWarningClose));
            }
            if(ObjectUtil.pathExists(m_window.closeWarning_mc,"continue_bt"))
            {
               closeWarning.addWidget(new FarmAnimatedTextButton(m_window.closeWarning_mc.continue_bt,ZLocUtils.t("Dialogs","Continue"),this.onCloseWarningContinue));
            }
            if(ObjectUtil.pathExists(m_window.closeWarning_mc,"generic_tf"))
            {
               closeWarning.addWidget(new ZwTextField(m_window.closeWarning_mc.generic_tf,UGCUtil.t(this.m_ugcItem,"closeWarning")));
            }
            addWidget(closeWarning,false);
         }
         if(ObjectUtil.pathExists(m_window,"asset_mc"))
         {
            assetPreviewFrame = new UGCItemPaintingFrame(m_window.asset_mc,this.m_ugcItem.farmItem,ASSET_PREVIEW_ZOOM_LEVEL);
            addWidget(assetPreviewFrame,true);
         }
         if(ObjectUtil.pathExists(m_window,"container_mc"))
         {
            this.m_editor = new UGCItemEditorFrame(m_window.container_mc,assetPreviewFrame,this.m_ugcItem,this.m_customizeItem);
            this.m_priceTextField.text = this.m_editor.totalCash.toString();
            this.m_editor.addEventListener(UGCConstants.EVENT_STATE_CHANGE,this.onItemStateChange);
            addWidget(this.m_editor,true);
         }
         if(ObjectUtil.pathExists(m_window,"horseName_mc"))
         {
            addWidget(new ZwTextField(m_window.horseName_mc.horseName_tf,UGCUtil.t(this.m_ugcItem,"setName")),true);
            addWidget(new ZwFrame(m_window.horseName_mc),false);
         }
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         ztrack(UGCConstants.STATS_PHYLUM_VIEW);
      }
      
      override protected function onClose(event:Event) : void
      {
         this.setCloseWarningVisibility(true);
      }
      
      override protected function release() : void
      {
         this.m_editor.removeEventListener(UGCConstants.EVENT_STATE_CHANGE,this.onItemStateChange);
         super.release();
         this.m_priceTextField = null;
         this.m_editor = null;
         this.m_ugcItem = null;
         this.m_howDoesThisWork = null;
      }
      
      private function setCloseWarningVisibility(visible:Boolean) : void
      {
         var closeWarning:ZwFrame = getWidget(m_window.closeWarning_mc) as ZwFrame;
         if(closeWarning != null)
         {
            if(visible != closeWarning.visible)
            {
               closeWarning.visible = visible;
            }
         }
      }
      
      private function onBuyClick(event:MouseEvent) : void
      {
         if(this.m_editor.totalCash > 10)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":this.m_editor.totalCash}),GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"farmAnimatedCashConfirmation",true,true);
         }
         else
         {
            this.buyAction();
         }
      }
      
      private function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.buyAction();
         }
      }
      
      private function buyAction() : void
      {
         var totalCash:int = 0;
         var state:UGCItemState = this.m_editor.ugcItemState;
         if(state.isValid())
         {
            totalCash = this.m_editor.totalCash;
            if(Global.player.canBuyCash(totalCash))
            {
               Utilities.toggleInputAndChildren(m_window,false);
               getWidget("buy_bt").visible = false;
               getWidget("creating_mc").visible = true;
               ztrack(STATS_PHYLUM_BUY);
               TransactionManager.addTransaction(new TCreateUGCItem(state,totalCash,this.m_editor.getCustomizeItem(),this.onCreateTxComplete),true);
            }
         }
      }
      
      private function onCreateTxComplete(ugcItemState:UGCItemState, existingItem:IUGCMapResource) : void
      {
         var extraData:Object = null;
         if(ugcItemState != null)
         {
            if(!existingItem)
            {
               extraData = {
                  "ugcUuid":ugcItemState.uuid,
                  "repopGift":false
               };
               Global.world.enterForcePlaceMode(this.m_ugcItem.farmItem.name,false,0,false,true,extraData);
            }
            else
            {
               existingItem.ugcDelegate.ugcItemState = ugcItemState;
            }
         }
         close();
      }
      
      private function onRandomClick(event:MouseEvent) : void
      {
         ztrack(UGCConstants.STATS_PHYLUM_RANDOMIZE);
         this.m_editor.randomize();
      }
      
      private function onResetClick(event:MouseEvent) : void
      {
         ztrack(UGCConstants.STATS_PHYLUM_RESET);
         this.m_editor.reset();
      }
      
      private function onCloseWarningClose(event:MouseEvent) : void
      {
         ztrack(UGCConstants.STATS_PHYLUM_CLOSE);
         close();
      }
      
      private function onCloseWarningContinue(event:MouseEvent) : void
      {
         this.setCloseWarningVisibility(false);
      }
      
      private function onItemStateChange(event:DynamicObjectEvent) : void
      {
         if(this.m_priceTextField)
         {
            this.m_priceTextField.text = this.m_editor.totalCash.toString();
            this.m_priceTextField.visible = true;
         }
      }
   }
}

