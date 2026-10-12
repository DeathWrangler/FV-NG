package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.Constants.MFSConstants;
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TTransformBuilding;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class StorageWithdrawalDynamicDialog extends FarmDynamicDialog implements ICellController
   {
      
      protected var m_requirementItemCell:BaseWidgetController;
      
      protected var m_completionItemCell:BaseWidgetController;
      
      private var m_building:StorageBuilding = null;
      
      protected var m_cashNeeded:int = 0;
      
      protected var m_enabled:Boolean = true;
      
      public function StorageWithdrawalDynamicDialog(view:BaseWidgetView)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","StorageWithdrawalDynamicDialog","called");
         super(view);
      }
      
      public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         var storagePartItem:PartItem = null;
         var haveNeededItems:Boolean = false;
         var askText:BaseWidgetController = null;
         var askButton:BaseWidgetController = null;
         var buyText:BaseWidgetController = null;
         var buyButton:BaseWidgetController = null;
         var item:FarmItem = null;
         var buyCostText:BaseWidgetController = null;
         var cashImage:BaseWidgetController = null;
         var buildingItem:FarmItem = null;
         var titleKey:String = null;
         var controller:BaseWidgetController = null;
         var buildingContents:Array = this.m_building.getConstructionItems();
         var isCompleteAllCell:Boolean = index == buildingContents.length ? true : false;
         newCell.destroy();
         if(!isCompleteAllCell)
         {
            storagePartItem = buildingContents[index] as PartItem;
            if(storagePartItem != null)
            {
               haveNeededItems = storagePartItem.onHand >= storagePartItem.qtyNeeded;
               newCell = this.m_requirementItemCell.clone();
               askText = newCell.getChildController("pos.askButton.base.text");
               askText.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","AskForParts"));
               askButton = newCell.getChildController("pos.askButton");
               askButton.index = index;
               askButton.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onAskButtonPress);
               buyText = newCell.getChildController("pos.row.buyButton.base.text");
               buyText.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","BuyParts"));
               buyButton = newCell.getChildController("pos.row.buyButton");
               buyButton.index = index;
               buyButton.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onBuyButtonPress);
               item = storagePartItem.item;
               buyCostText = newCell.getChildController("pos.row.costText");
               buyCostText.setAttribute(TextFieldView.ATTRIBUTE_TEXT,Utilities.formatNumber(item.cash));
               cashImage = newCell.getChildController("pos.row.cashImage");
               if(haveNeededItems)
               {
                  askText.getView().visible = false;
                  askButton.getView().visible = false;
                  buyText.getView().visible = false;
                  buyButton.getView().visible = false;
                  buyCostText.getView().visible = false;
                  cashImage.getView().visible = false;
                  controller = newCell.getChildController("pos.itemDesc");
                  if(controller != null)
                  {
                     controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","PartComplete"));
                  }
               }
               controller = newCell.getChildController("pos.pad.box.image");
               if(controller != null)
               {
                  controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,item.iconUrl);
               }
               controller = newCell.getChildController("pos.itemName");
               if(controller != null)
               {
                  controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,item.friendlyTitle);
               }
               controller = newCell.getChildController("pos.itemQty");
               if(controller != null)
               {
                  controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
                     "quantity":storagePartItem.onHand,
                     "maximum":storagePartItem.qtyNeeded
                  }));
               }
            }
         }
         else
         {
            newCell = this.m_completionItemCell.clone();
            controller = newCell.getChildController("pos.sendButton.base.text");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","SendGifts"));
            }
            controller = newCell.getChildController("pos.sendButton");
            if(controller != null)
            {
               controller.index = index;
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onSendGiftsPress);
            }
            controller = newCell.getChildController("pos.completeButton.base.text");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","CompleteNow"));
            }
            controller = newCell.getChildController("pos.completeButton");
            if(controller != null)
            {
               controller.index = index;
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onCompleteNowPress);
            }
            buildingItem = this.m_building.getItem();
            if(buildingItem != null)
            {
               controller = newCell.getChildController("pos.pad.box.image");
               if(controller != null)
               {
                  controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,buildingItem.iconUrl);
               }
               controller = newCell.getChildController("pos.itemName");
               if(controller != null)
               {
                  titleKey = null;
                  if(ZLocUtils.hasString("Items",buildingItem.name + "_shortFriendlyName"))
                  {
                     titleKey = "Items:" + buildingItem.name + "_shortFriendlyName";
                  }
                  else
                  {
                     titleKey = buildingItem.friendlyName;
                  }
                  controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.tk_pk_asTitle(titleKey));
               }
            }
         }
         return newCell;
      }
      
      private function setupWhatIsThisButton() : void
      {
         var message:String = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "StorageWithdrawalWhatIsThis");
         if(Boolean(message) && message != "")
         {
            this.getShortcutController("whatsThisView").setAttribute("visible","true");
            this.getShortcutController("whatsThis").getChildController("whatIsThisButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onWhatIsThisPress);
         }
      }
      
      private function onWhatIsThisPress(event:WidgetControllerEvent) : void
      {
         var message:String = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "StorageWithdrawalWhatIsThis");
         UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
      }
      
      override public function show(addToQueue:Boolean = false, popupName:String = "", checkDuplicates:Boolean = false) : void
      {
         super.show(addToQueue);
         var defaultAction:String = this.getImport("defaultAction") as String;
         switch(defaultAction)
         {
            case ConstructionBuilding.MENU_ASK_FOR_PARTS:
               FarmStatsManager.count(this.m_building.getItem().name,"context_menu","ask_for_parts");
               this.askForPartsHandler(this.m_building.getMostNeededItem());
               break;
            case ConstructionBuilding.MENU_COMPLETE_NOW:
               FarmStatsManager.count(this.m_building.getItem().name,"context_menu","complete_now");
               this.completeNowHandler();
         }
      }
      
      override public function setup() : void
      {
         this.m_building = this.getImport("building") as StorageBuilding;
         super.setup();
         var controller:BaseWidgetController = null;
         this.m_requirementItemCell = (this.getImport("GenericWithdrawalRequirementItemCell") as BaseWidgetView).getController();
         this.m_completionItemCell = (this.getImport("GenericWithdrawalCompletionItemCell") as BaseWidgetView).getController();
         var title:String = this.getImport("title") as String;
         if(!title)
         {
            title = ZLocUtils.t("Dialogs",m_view.name + "Title");
         }
         this.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,title);
         controller = getShortcutController("itemCell");
         if(controller)
         {
            controller.setAttribute(CellController.ATTRIBUTE_CREATE,this);
            controller.setAttribute(CellController.ATTRIBUTE_CELL_COUNT,this.m_building.getConstructionItems().length + 1);
         }
         var isHalfwayComplete:Boolean = this.m_building.getPartsOnHand() >= this.m_building.capacity / 2;
         var shortcutController:BaseWidgetController = this.getShortcutController("body");
         var newStyle:BaseStyle = null;
         var checkForStyle:BaseStyle = MT4DManager.getInstance().getStyle(m_view.name + "HalfwayBg");
         if(isHalfwayComplete && checkForStyle != null)
         {
            newStyle = MT4DManager.getInstance().getStyle(m_view.name + "HalfwayBg");
         }
         else
         {
            newStyle = MT4DManager.getInstance().getStyle(m_view.name + "StartBg");
         }
         shortcutController.setAttribute("style",newStyle);
         this.setupWhatIsThisButton();
      }
      
      private function onAskButtonPress(event:WidgetControllerEvent) : void
      {
         var storagePartItem:PartItem = this.getCellItem(event.getController().index);
         FarmStatsManager.count(this.m_building.getItem().name,"level1","ask_for_part",storagePartItem.item.name);
         this.askForPartsHandler(storagePartItem);
      }
      
      private function askForPartsHandler(storagePartItem:PartItem) : void
      {
         if(storagePartItem)
         {
            FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r2FlowCalled","StorageWithdrawalDynamicDialog");
            MFSRequestManager.getInstance().makeAskMatsRequest(this.m_building.getItem().name,storagePartItem.item.name,this.m_building.getItem().name,"",MFSConstants.SOURCE_DIALOG_CLICKED,"Constructable","ui_button_click",this.m_building.getItem().name,"ask_for_more");
         }
      }
      
      private function onBuyButtonPress(event:WidgetControllerEvent) : void
      {
         var itemToBuy:FarmItem = null;
         var storagePartItem:PartItem = this.getCellItem(event.getController().index);
         if(storagePartItem)
         {
            itemToBuy = storagePartItem.item;
            if(Boolean(itemToBuy) && this.m_enabled)
            {
               if(Global.player.canBuyCash(itemToBuy.cash,true))
               {
                  BuildingItemUseMediator.getInstance().mediate(itemToBuy.name,false,this.m_building);
                  FarmStatsManager.count("Constructable","ui_button_click",this.m_building.getItem().name,"buy_part",itemToBuy.name,"accept");
                  FarmStatsManager.count("dialog",this.m_building.getItem().name,"level1","buy_" + itemToBuy.name,"accept");
                  this.destroy();
               }
            }
         }
      }
      
      private function onCompleteNowPress(event:WidgetControllerEvent) : void
      {
         if(this.m_enabled)
         {
            this.m_enabled = false;
            this.completeNowHandler();
         }
      }
      
      private function completeNowHandler() : void
      {
         var buildingName:String = null;
         var msg:String = null;
         var dialog:GenericXMLDialog = null;
         this.m_cashNeeded = this.m_building.getCashNeeded();
         if(this.m_cashNeeded > 0)
         {
            buildingName = this.m_building.getItemFriendlyName();
            msg = ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
               "cashQuantity":this.m_cashNeeded,
               "item":ZLocUtils.tk_pk(buildingName)
            });
            dialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,this.onCompleteNowAcceptCallback,true,ZLocUtils.t("Dialogs","Okay"));
            UI.displayPopup(dialog,false);
         }
         else
         {
            this.frictionlessCompleteNow();
            this.destroy();
         }
      }
      
      private function onCompleteNowAcceptCallback(event:GenericPopupEvent) : void
      {
         this.m_enabled = true;
         if(event.button == GenericPopup.YES)
         {
            this.frictionlessCompleteNow();
            FarmStatsManager.count("Constructable","ui_button_click",this.m_building.getItem().name + this.m_building.storageLevel.toString(),"complete_now","accept");
            FarmStatsManager.count("dialog",this.m_building.getItem().name,"level1-" + this.m_building.storageLevel.toString(),"complete_now","okay");
            this.destroy();
         }
         else
         {
            FarmStatsManager.count("Constructable","ui_button_click",this.m_building.getItem().name + this.m_building.storageLevel.toString(),"complete_now","cancel");
            FarmStatsManager.count("dialog",this.m_building.getItem().name,"level1-" + this.m_building.storageLevel.toString(),"complete_now","x_button");
         }
      }
      
      private function frictionlessCompleteNow() : void
      {
         var cBuilding:ConstructionBuilding = null;
         var newBuilding:Object = null;
         var fBuilding:FeatureBuilding = null;
         if(this.m_building is ConstructionBuilding)
         {
            cBuilding = this.m_building as ConstructionBuilding;
            if(cBuilding != null && Global.player.canBuyCash(this.m_cashNeeded))
            {
               newBuilding = cBuilding.transformBuilding() as Object;
               if(newBuilding)
               {
                  Global.player.tryBuy(newBuilding as MapResource,false,newBuilding.getItem(),newBuilding.getItem().cash - this.m_cashNeeded);
                  TransactionManager.addTransaction(new TTransformBuilding(cBuilding));
               }
            }
         }
         else if(this.m_building is FeatureBuilding)
         {
            fBuilding = this.m_building as FeatureBuilding;
            if(Boolean(fBuilding) && Global.player.canBuyCash(this.m_cashNeeded))
            {
               fBuilding.frictionlessExpand();
            }
         }
      }
      
      protected function onSendGiftsPress(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(this.m_building.getItem().name,"level1-" + this.m_building.storageLevel.toString(),"send_gifts");
         destroy();
         UI.displayPopup(new CustomFreeGiftSelectionWindow(this.m_building.getPartsArray()));
         var buildingRefName:String = this.m_building.getItem().name + this.m_building.storageLevel.toString();
         FarmStatsManager.count("Constructable","ui_button_click",buildingRefName,"send_gifts");
      }
      
      private function getCellItem(index:Number) : PartItem
      {
         var buildingContents:Array = this.m_building.getConstructionItems();
         return buildingContents[index] as PartItem;
      }
   }
}

