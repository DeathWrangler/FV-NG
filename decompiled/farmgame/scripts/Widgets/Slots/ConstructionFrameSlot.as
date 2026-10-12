package Widgets.Slots
{
   import Classes.BuildingItemUseMediator;
   import Classes.Constants.MFSConstants;
   import Classes.ConstructionBuilding;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TTransformBuilding;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   
   public class ConstructionFrameSlot extends ZwSlotFrame
   {
      
      protected const ASK_MATERIALS_URL:String = "askmats.php";
      
      protected var m_building:StorageBuilding;
      
      protected var m_itemToBuy:FarmItem;
      
      protected var m_data:Object;
      
      protected var m_window:FarmWindow;
      
      public function ConstructionFrameSlot(element:DisplayObject, storage:StorageBuilding, parentWindow:FarmWindow)
      {
         FarmStatsManager.sample(1000,"fv_fbml_depr_inspect","ConstructionFrameSlot","called");
         this.m_window = parentWindow;
         this.m_building = storage;
         super(element);
      }
      
      public static function getClassName(object:Object) : String
      {
         var splitString:Array = getQualifiedClassName(object).split("::");
         return splitString.pop();
      }
      
      override public function clearView() : void
      {
      }
      
      override public function populate(data:Object) : void
      {
         var ci:ZwFrame = null;
         var buyButton:FarmAnimatedButton = null;
         var getThis:FarmAnimatedTextButton = null;
         var sendMats:ZwTextField = null;
         var sendGifts:FarmButton = null;
         super.populate(data);
         this.m_data = data;
         this.visible = true;
         addWidget(new FarmButton(element.use_bt),false);
         if(data.sendGiftsToFriends == false)
         {
            addWidget(new ZwTextField(element.itemTitle_tf,ZLocUtils.tk_pk_asTitle(data.localizedName)));
            addWidget(new ZwTextField(element.alive_tf,ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
               "quantity":data.amount,
               "maximum":data.need
            })));
            addWidget(new ZwFrame(element.iconBox_mc),true);
            if(data.amount == data.need)
            {
               addWidget(ci = new ZwFrame(element.completeIcon_mc),true);
               ci.addWidget(new ZwTextField(ci.element.completed_tf,ZLocUtils.t("Dialogs","GenericExpansion_completed_text")));
               addWidget(new FarmButton(element.getThis_bt),false);
               addWidget(new ZwFrame(element.completeNow_bt),false);
               addWidget(new ZwFrame(element.buy_bt),false);
            }
            else
            {
               addWidget(new ZwFrame(element.completeIcon_mc),false);
               addWidget(new ZwFrame(element.completeNow_bt),false);
               buyButton = new FarmAnimatedButton(element.buy_bt,this.onBuyCallback);
               addWidget(buyButton,true);
               addWidget(getThis = new FarmAnimatedTextButton(element.getThis_bt,ZLocUtils.t("Dialogs","AskForMore"),this.onGetThisCallback));
               if(this.getThisGreyOut() || !this.isAskSendEnabled())
               {
                  getThis.applyGrayOut = true;
                  getThis.enabled = false;
               }
               if(!this.isAskSendEnabled())
               {
                  buyButton.applyGrayOut = true;
                  buyButton.enabled = false;
               }
            }
            addWidget(new ZwTextField(element.sendMaterials_tf),false);
            addWidget(new ZwFrame(element.present_bt),false);
            this.addIcon(data.name,"icon",element as MovieClip,element.icon as MovieClip);
         }
         else
         {
            addWidget(new ZwFrame(element.itemTitle_tf),false);
            addWidget(new ZwFrame(element.alive_tf),false);
            addWidget(new ZwFrame(element.completeIcon_mc),false);
            addWidget(new ZwFrame(element.getThis_bt),false);
            addWidget(new ZwFrame(element.iconBox_mc),false);
            addWidget(new ZwFrame(element.buy_bt),false);
            addWidget(sendMats = new ZwTextField(element.sendMaterials_tf));
            if(this.isAskSendEnabled())
            {
               sendMats.text = ZLocUtils.t("Dialogs","SendMaterials");
               addWidget(new FarmAnimatedTextButton(element.present_bt,ZLocUtils.t("Dialogs","SendGiftsBig"),this.onSendPresentsCallback));
            }
            else
            {
               sendMats.text = ZLocUtils.t("Dialogs","FinishConstructionNow",{"quantity":data.cashNeeded});
               addWidget(new ZwFrame(element.present_bt),false);
            }
            addWidget(new FarmAnimatedTextButton(element.completeNow_bt,ZLocUtils.t("Dialogs","CompleteNow"),this.onFinishConstructionCallback));
         }
      }
      
      protected function onBuyCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",this.m_building.getItem().name,"buy_part");
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
            "cashQuantity":this.m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyConfirmationHandler),false);
         this.m_window.close();
      }
      
      private function buyConfirmationHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            if(Global.player.canBuyCash(this.m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(this.m_itemToBuy.name,false,this.m_building);
            }
         }
      }
      
      protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         this.m_window.close();
         FreeGiftSelectionWindow.popWindow();
      }
      
      protected function onFinishConstructionCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Finish_construction_click");
         FarmStatsManager.count("Constructable","ui_button_click",this.m_building.getItem().name,"complete_now");
         var buildingName:String = this.m_building.getItemFriendlyName();
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":this.m_data.cashNeeded,
            "item":ZLocUtils.tk_pk(buildingName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup);
         this.m_window.close();
      }
      
      protected function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         var cBuilding:ConstructionBuilding = null;
         var newBuilding:Object = null;
         var discount:int = 0;
         if(event.button == GenericPopup.YES)
         {
            cBuilding = this.m_building as ConstructionBuilding;
            if(cBuilding != null && Global.player.canBuyCash(this.m_data.cashNeeded))
            {
               newBuilding = cBuilding.transformBuilding() as Object;
               if(newBuilding)
               {
                  discount = newBuilding.getItem().cash - this.m_data.cashNeeded;
                  Global.player.tryBuy(newBuilding as MapResource,false,newBuilding.getItem(),discount);
                  TransactionManager.addTransaction(new TTransformBuilding(cBuilding));
               }
            }
         }
      }
      
      protected function onGetThisCallback(event:MouseEvent) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         FarmStatsManager.count("Constructable","ui_button_click",this.m_building.getItem().name,"ask_for_more");
         MFSRequestManager.getInstance().makeAskMatsRequest(this.m_building.getItem().name,item.name,this.m_building.getItem().name,"",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      protected function addIcon(itemName:String, imageName:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50) : void
      {
         var icon:Loader = null;
         var url:String = Global.farmGameSettingsManager.getImageByName(itemName,imageName);
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               if(tile)
               {
                  Utilities.removeAllChildren(movieClip);
               }
               dispObj = icon.content;
               dispObj.width = width;
               dispObj.height = height;
               movieClip.addChild(dispObj);
            }
         });
      }
      
      protected function getThisGreyOut() : Boolean
      {
         var result:Boolean = false;
         var flagName:String = getClassName(this);
         var timeSinceAsk:Number = GlobalEngine.serverTime / 1000 - Global.player.getFeatureLastShown(flagName);
         if(timeSinceAsk < Global.farmGameSettingsManager.getNumber("constructionMaterialAskDelay"))
         {
            result = true;
         }
         return result;
      }
      
      protected function isAskSendEnabled() : Boolean
      {
         var endTime:Number = NaN;
         var result:Boolean = true;
         var disableDate:String = this.getAskSendDisableDate();
         if(disableDate)
         {
            endTime = FarmGameUtil.synchronizedDateToNumber(disableDate);
            result = GlobalEngine.getTimer() < endTime;
         }
         return result;
      }
      
      protected function getAskSendDisableDate() : String
      {
         return this.m_building.getItem().limitedEndDate;
      }
   }
}

