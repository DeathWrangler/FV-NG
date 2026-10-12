package Display
{
   import Classes.IUser;
   import Classes.ZItem.FarmItem;
   import Classes.unwither.UnwitherUtils;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFieldType;
   
   public class CustomizeRing extends Dialog
   {
      
      protected const MESSAGE_BOX_CHAR_LIMIT:int = 140;
      
      protected const FRAME_NORMAL:int = 1;
      
      protected const FRAME_MOUSE_OVER:int = 2;
      
      protected const FRAME_SELECTED:int = 3;
      
      protected var m_customizeItem:FarmItem;
      
      protected var m_customize:Boolean = false;
      
      protected var m_ringID:Number;
      
      protected var m_receiver:IUser;
      
      protected var m_customItemData:Object = null;
      
      protected var m_metals:Array = new Array();
      
      protected var m_gems:Array = new Array();
      
      protected var m_selectedMetal:int = 0;
      
      protected var m_selectedGem:int = 0;
      
      protected var m_selected:String = "ringgolddiamond";
      
      public function CustomizeRing(customizeItem:FarmItem, receiver:IUser, customize:Boolean = false, ringID:Number = 0)
      {
         m_dialogAsset = "assets/dialogs/FV_Unwither_customize.swf";
         this.m_customizeItem = customizeItem;
         this.m_receiver = receiver;
         this.m_customize = customize;
         this.m_ringID = ringID;
         super();
      }
      
      public function getCustomRingData() : Object
      {
         return this.m_customItemData;
      }
      
      public function getCustomItem() : FarmItem
      {
         return this.m_customizeItem;
      }
      
      public function getRingID() : Number
      {
         return this.m_ringID;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.setupDialogTextAndButtons();
         this.setupMetalOptions();
         this.setupGemOptions();
         this.selectRing(this.m_selectedMetal,this.m_selectedGem);
         this.setSelectItemIcon();
         this.setSelectItemIcon();
      }
      
      protected function setupDialogTextAndButtons() : void
      {
         var genericButton:GenericButton = null;
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
         if(!this.m_customize)
         {
            genericButton = new GenericButton(m_window.buy_bt,this.onBuy,ZLocUtils.t("Dialogs","Buy"));
            genericButton.text = ZLocUtils.t("Dialogs","Buy");
         }
         else
         {
            genericButton = new GenericButton(m_window.buy_bt,this.onBuy,ZLocUtils.t("Dialogs","CustomizeRingEditRing"));
            genericButton.text = ZLocUtils.t("Dialogs","CustomizeRingEditRing");
         }
         m_window.genericButton = genericButton;
         m_window.unwitherTitle_tf.text = ZLocUtils.t("Dialogs","CustomizeRingTitle");
         if(this.m_receiver != null)
         {
            m_window.recipient_tf.text = ZLocUtils.t("Dialogs","CustomizeRingRecipientLabel");
            m_window.name_tf.text = this.m_receiver.name;
         }
         else
         {
            m_window.recipient_tf.visible = false;
            m_window.name_tf.visible = false;
         }
         m_window.chooseMetal_tf.text = ZLocUtils.t("Dialogs","CustomizeRingMetelLabel");
         m_window.chooseGem_tf.text = ZLocUtils.t("Dialogs","CustomizeRingGemLabel");
         m_window.personalMsg_tf.text = ZLocUtils.t("Dialogs","CustomizeRingPersonalMessageLabel");
         m_window.charLimit_tf.text = ZLocUtils.t("Dialogs","CustomizeRingCharLimitLabel");
         var cash:String = this.m_customizeItem.realCashCost.toString();
         if(!this.m_customize)
         {
            m_window.charged_tf.text = ZLocUtils.t("Dialogs","CustomizeRingChargeMsg",{"cashQuantity":cash});
         }
         else
         {
            m_window.charged_tf.visible = false;
         }
         m_window.message_tf.type = TextFieldType.INPUT;
         m_window.message_tf.maxChars = this.MESSAGE_BOX_CHAR_LIMIT;
         m_window.message_tf.text = ZLocUtils.t("Dialogs","CustomizeRingPersonalMessageDefaultText");
      }
      
      protected function setupMetalOptions() : void
      {
         var metalIDx:int;
         var index:Number = NaN;
         var url:String = null;
         var icon:Loader = null;
         var metal:Object = null;
         var metalList:Array = this.m_customizeItem.getMetalList();
         for(metalIDx = 0; metalIDx < metalList.length; metalIDx++)
         {
            index = metalIDx + 1;
            url = Global.getAssetURL(metalList[metalIDx].url);
            icon = LoadingManager.load(url,function(event:Event):void
            {
               var dispObj:* = undefined;
               var icon:* = event.target;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  dispObj = icon.content;
                  dispObj.width = 50;
                  dispObj.height = 50;
                  m_window[icon.loader.name].addChild(dispObj);
                  Utilities.toggleInputOnlySelf(m_window[icon.loader.name],false);
               }
            });
            icon.name = "metalIcon" + index.toString();
            metal = new Object();
            metal.name = metalList[metalIDx].name;
            m_window["metalTitle" + index.toString() + "_tf"].text = ZLocUtils.t("Dialogs",metal.name);
            metal.selector = m_window["metalCell" + index.toString() + "_mc"];
            metal.selector.value = metalIDx;
            metal.selector.addEventListener(MouseEvent.MOUSE_OVER,this.onMetalTileMouseOver,false,0,true);
            metal.selector.addEventListener(MouseEvent.MOUSE_OUT,this.onMetalTileMouseOut,false,0,true);
            metal.selector.addEventListener(MouseEvent.CLICK,this.onMetalTileMouseClick,false,0,true);
            if(this.m_selectedMetal == metalIDx)
            {
               (metal.selector as MovieClip).gotoAndStop(3);
            }
            this.m_metals[metalIDx] = metal;
         }
      }
      
      protected function setupGemOptions() : void
      {
         var gemIDx:int;
         var index:Number = NaN;
         var gem:Object = null;
         var url:String = null;
         var icon:Loader = null;
         var gemList:Array = this.m_customizeItem.getGemList();
         for(gemIDx = 0; gemIDx < gemList.length; gemIDx++)
         {
            index = gemIDx + 1;
            if(gemList[gemIDx].url != "")
            {
               url = Global.getAssetURL(gemList[gemIDx].url);
               icon = LoadingManager.load(url,function(event:Event):void
               {
                  var dispObj:* = undefined;
                  var icon:* = event.target;
                  if(Boolean(icon) && Boolean(icon.content))
                  {
                     dispObj = icon.content;
                     dispObj.width = 50;
                     dispObj.height = 50;
                     m_window[icon.loader.name].addChild(dispObj);
                     Utilities.toggleInputOnlySelf(m_window[icon.loader.name],false);
                  }
               });
               icon.name = "gemIcon" + index.toString();
            }
            gem = new Object();
            gem.name = gemList[gemIDx].name;
            m_window["gemTitle" + index.toString() + "_tf"].text = ZLocUtils.t("Dialogs",gem.name);
            gem.selector = m_window["gemCell" + index.toString() + "_mc"];
            gem.selector.value = gemIDx;
            gem.selector.addEventListener(MouseEvent.MOUSE_OVER,this.onGemTileMouseOver,false,0,true);
            gem.selector.addEventListener(MouseEvent.MOUSE_OUT,this.onGemTileMouseOut,false,0,true);
            gem.selector.addEventListener(MouseEvent.CLICK,this.onGemTileMouseClick,false,0,true);
            if(this.m_selectedGem == gemIDx)
            {
               (gem.selector as MovieClip).gotoAndStop(3);
            }
            this.m_gems[gemIDx] = gem;
         }
      }
      
      protected function setSelectItemIcon() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_selected);
         var icon:Loader = LoadingManager.load(item.icon,function(event:Event):void
         {
            var dispObj:* = undefined;
            var icon:* = event.target;
            if(Boolean(icon) && Boolean(icon.content))
            {
               Utilities.removeAllChildren(m_window.ringIcon_mc);
               dispObj = icon.content;
               dispObj.width = 100;
               dispObj.height = 100;
               dispObj.x = (m_window.ringIcon_mc.width - dispObj.width) / 2;
               dispObj.y = (m_window.ringIcon_mc.height - dispObj.height) / 2;
               m_window.ringIcon_mc.addChild(dispObj);
            }
         });
      }
      
      protected function onMetalTileMouseOver(event:MouseEvent) : void
      {
         var tile:MovieClip = event.target as MovieClip;
         if(this.m_selectedMetal != tile.value)
         {
            tile.gotoAndStop(2);
         }
      }
      
      protected function onMetalTileMouseOut(event:MouseEvent) : void
      {
         var tile:MovieClip = event.target as MovieClip;
         if(this.m_selectedMetal != tile.value)
         {
            tile.gotoAndStop(1);
         }
      }
      
      protected function onMetalTileMouseClick(event:MouseEvent) : void
      {
         var tile:MovieClip = event.target as MovieClip;
         if(this.m_selectedMetal != tile.value)
         {
            (this.m_metals[this.m_selectedMetal].selector as MovieClip).gotoAndStop(1);
            this.m_selectedMetal = tile.value;
            this.selectRing(this.m_selectedMetal,this.m_selectedGem);
            this.setSelectItemIcon();
            tile.gotoAndStop(3);
         }
      }
      
      protected function onGemTileMouseOver(event:MouseEvent) : void
      {
         var tile:MovieClip = event.target as MovieClip;
         if(this.m_selectedGem != tile.value)
         {
            tile.gotoAndStop(2);
         }
      }
      
      protected function onGemTileMouseOut(event:MouseEvent) : void
      {
         var tile:MovieClip = event.target as MovieClip;
         if(this.m_selectedGem != tile.value)
         {
            tile.gotoAndStop(1);
         }
      }
      
      protected function onGemTileMouseClick(event:MouseEvent) : void
      {
         var tile:MovieClip = event.target as MovieClip;
         if(this.m_selectedGem != tile.value)
         {
            (this.m_gems[this.m_selectedGem].selector as MovieClip).gotoAndStop(1);
            this.m_selectedGem = tile.value;
            this.selectRing(this.m_selectedMetal,this.m_selectedGem);
            this.setSelectItemIcon();
            tile.gotoAndStop(3);
         }
      }
      
      private function getBaseRingType(code:String) : String
      {
         var result:String = "ring";
         if(UnwitherUtils.isItemUnwitherRingbox(code))
         {
            result = UnwitherUtils.getWorldUnwitherPrefixByItemCode(code);
         }
         return result;
      }
      
      private function selectRing(metal:int, gem:int) : void
      {
         var baseType:String = this.getBaseRingType(this.m_customizeItem.code);
         if(this.m_gems[gem].name != "none")
         {
            this.m_selected = baseType + this.m_metals[metal].name + this.m_gems[gem].name;
         }
         else
         {
            this.m_selected = baseType + this.m_metals[metal].name;
         }
      }
      
      protected function onBuy(event:MouseEvent) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_selected);
         this.m_customItemData = new Object();
         this.m_customItemData.sender = Global.player.snUser.uid.toString();
         this.m_customItemData.ringType = item.code;
         this.m_customItemData.message = m_window.message_tf.text;
         this.m_customItemData.opened = false;
         this.m_customItemData.world = UnwitherUtils.getUnwitherWorldfromCode(item.code);
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         m_window.genericButton.turnOff();
         close();
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         m_window.genericButton.turnOff();
         close();
      }
   }
}

