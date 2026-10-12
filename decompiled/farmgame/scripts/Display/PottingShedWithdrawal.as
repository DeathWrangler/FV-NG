package Display
{
   import Classes.HarvestStorageBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TGiftFlowerDecorations;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PottingShedWithdrawal extends StorageWithdrawal
   {
      
      private const NUM_SLOTS:int = 6;
      
      private const MAX_SHARE_AMOUNT:int = 5;
      
      protected var m_shareItemCode:String;
      
      protected var m_sharePopup:ShareFlowersDialog = null;
      
      public function PottingShedWithdrawal(storage:StorageBuilding)
      {
         m_dialogAsset = "assets/dialogs/FV_PottingShed.swf";
         m_dialogType = "pottingshed";
         super(storage);
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function pushNewData() : void
      {
         var objectIdx:int = 0;
         var object:Object = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         var giftXML:XML = null;
         m_data = [];
         m_tileSet = 0;
         m_usedTypes = new Object();
         var objects:Array = m_building.getContents();
         if(objects)
         {
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               object = new Object();
               giftItem = objects[objectIdx].item;
               giftNum = Number(objects[objectIdx].num);
               if(m_usedTypes[giftItem.code] == null)
               {
                  m_usedTypes[giftItem.code] = giftNum;
                  object.name = giftItem.name;
                  object.code = giftItem.code;
                  object.type = giftItem.type;
                  object.localizedName = giftItem.friendlyName;
                  object.cost = giftItem.cost;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     if(giftItem.hasPropertyInDataSource("coinYield"))
                     {
                        object.coinYield = giftItem.getNumberFromDataSource("coinYield");
                     }
                     if(giftItem.hasPropertyInDataSource("growTime"))
                     {
                        object.harvestTime = giftItem.getNumberFromDataSource("growTime");
                     }
                     if(giftItem.hasPropertyInDataSource("sizeX"))
                     {
                        object.sizeX = giftItem.getNumberFromDataSource("sizeX");
                     }
                     if(giftItem.hasPropertyInDataSource("sizeY"))
                     {
                        object.sizeX = giftItem.getNumberFromDataSource("sizeY");
                     }
                     if(giftItem.hasPropertyInDataSource("liveTime"))
                     {
                        object.liveTime = giftItem.getNumberFromDataSource("liveTime");
                     }
                  }
                  else
                  {
                     giftXML = giftItem.xml;
                     if(giftXML.coinYield)
                     {
                        object.coinYield = giftXML.coinYield;
                     }
                     if(giftXML.growTime)
                     {
                        object.harvestTime = giftXML.growTime;
                     }
                     if(giftItem.sizeX)
                     {
                        object.sizeX = giftItem.sizeX;
                     }
                     if(giftItem.sizeY)
                     {
                        object.sizeX = giftItem.sizeY;
                     }
                     if(giftXML.liveTime)
                     {
                        object.liveTime = giftXML.liveTime;
                     }
                  }
                  m_data.push(object);
               }
               else
               {
                  m_usedTypes[objects[objectIdx].itemCode] += 1;
               }
            }
         }
         fixArrows();
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var mc:MovieClip = null;
         var shareBtn:GenericButton = null;
         var shareAmount:int = 0;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            mc = m_tiles[compId] as MovieClip;
            m_tiles[compId].visible = true;
            m_tiles[compId].itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].localizedName);
            m_tiles[compId].whatisthis_mc.visible = false;
            m_tiles[compId].trade_bt.visible = false;
            if(m_data[index + compId].liveTime.toString() != "")
            {
               m_tiles[compId].alive_tf.visible = true;
               m_tiles[compId].alive_tf.text = ZLocUtils.t("Dialogs","LiveTime",{"quantity":m_data[index + compId].liveTime});
            }
            else if(m_tiles[compId].alive_tf)
            {
               m_tiles[compId].alive_tf.visible = false;
            }
            m_tiles[compId].giftAmount_tf.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":m_usedTypes[m_data[index + compId].code]});
            if(m_tiles[compId].share_bt)
            {
               m_tiles[compId].share_bt.visible = true;
               shareBtn = new GenericButton(m_tiles[compId].share_bt,this.onShare);
               shareBtn.m_overlay.name = m_data[index + compId].name;
               shareAmount = this.MAX_SHARE_AMOUNT;
               if(m_usedTypes[m_data[index + compId].code] < 5)
               {
                  shareAmount = int(m_usedTypes[m_data[index + compId].code]);
               }
               shareBtn.text = ZLocUtils.t("Dialogs","ShareItem",{"quantity":shareAmount});
            }
            else
            {
               m_tiles[compId].share_bt.visible = false;
            }
            m_buttons[compId] = new GenericButton(m_tiles[compId].use_bt,onUse);
            m_buttons[compId].m_overlay.name = m_data[index + compId].name;
            m_buttons[compId].text = ZLocUtils.t("Dialogs","Use");
            addIcon(m_data[index + compId].name,"icon",m_tiles[compId],m_tiles[compId].icon);
         }
      }
      
      protected function onShare(event:Event) : void
      {
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(event.target.name);
         if(Global.player.isSharingFlowers)
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","BusySharing")),false);
         }
         else if(Boolean(giftItem) && this.m_sharePopup == null)
         {
            this.m_shareItemCode = giftItem.code;
            this.m_sharePopup = new ShareFlowersDialog(giftItem.name,m_usedTypes[this.m_shareItemCode],m_building.getItem().name,this.onConfirmShare);
            UI.displayPopup(this.m_sharePopup,false);
         }
      }
      
      protected function onConfirmShare(event:GenericPopupEvent) : void
      {
         var itemCount:int = 0;
         if(event.button == GenericPopup.YES)
         {
            itemCount = this.m_sharePopup.getItemCount();
            m_building.removeContents(this.m_shareItemCode,itemCount);
            Global.player.isSharingFlowers = true;
            TransactionManager.addTransaction(this.createShareTransaction(itemCount));
            this.onCloseClick(new MouseEvent(MouseEvent.CLICK));
            FarmStatsManager.count(m_dialogType,"click_give");
         }
         this.m_sharePopup = null;
      }
      
      protected function createShareTransaction(itemCount:int) : Transaction
      {
         return new TGiftFlowerDecorations(m_building as HarvestStorageBuilding,this.m_shareItemCode,itemCount,this.onFinishShareFeed);
      }
      
      protected function onFinishShareFeed() : void
      {
         Global.player.isSharingFlowers = false;
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         if(null != this.m_sharePopup)
         {
            this.m_sharePopup.close();
         }
         super.onCloseClick(event);
      }
   }
}

