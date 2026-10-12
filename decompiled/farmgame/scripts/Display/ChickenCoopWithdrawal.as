package Display
{
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Widgets.Frames.SearchFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ChickenCoopWithdrawal extends StorageWithdrawal
   {
      
      private const NUM_SLOTS:int = 4;
      
      protected var m_searchFrame:SearchFrame;
      
      protected var m_searchString:String = "";
      
      public function ChickenCoopWithdrawal(storage:StorageBuilding)
      {
         m_dialogAsset = "assets/dialogs/FV_ChickenCoop.swf";
         m_dialogType = "chickenCoop";
         super(storage);
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         if(m_window.gifts_mc.hasOwnProperty("searchBar_mc"))
         {
            this.m_searchFrame = new SearchFrame(m_window.gifts_mc.searchBar_mc,this.onSearchUpdate);
            this.m_searchFrame.alpha = 100;
         }
      }
      
      private function onSearchUpdate(searchString:String = "") : void
      {
         this.m_searchString = searchString;
         removeTiles();
         this.pushNewData();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
      }
      
      override protected function pushNewData() : void
      {
         var objectIdx:int = 0;
         var object:Object = null;
         var giftObj:Object = null;
         var giftNum:Number = NaN;
         var friendlyName:String = null;
         m_data = [];
         m_tileSet = 0;
         m_usedTypes = new Object();
         var objects:Array = m_building.getStorageTypes();
         if(objects)
         {
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               object = new Object();
               giftObj = objects[objectIdx].item;
               giftNum = Number(objects[objectIdx].num);
               if(giftNum > 0 || giftObj is FarmItem && (giftObj as FarmItem).canShow())
               {
                  if(m_usedTypes[giftObj.code] == null)
                  {
                     m_usedTypes[giftObj.code] = giftNum;
                     object.name = giftObj.name;
                     object.code = giftObj.code;
                     object.type = giftObj.type;
                     object.localizedName = Global.farmGameSettingsManager.getFarmItemByName(object.name).friendlyName;
                     object.cost = giftObj.cost;
                     object.count = giftNum;
                     if(giftObj.coinYield)
                     {
                        object.coinYield = giftObj.coinYield;
                     }
                     if(giftObj.growTime)
                     {
                        object.harvestTime = giftObj.growTime;
                     }
                     if(giftObj.sizeX)
                     {
                        object.sizeX = giftObj.sizeX;
                     }
                     if(giftObj.sizeY)
                     {
                        object.sizeX = giftObj.sizeY;
                     }
                     if(giftObj.harvestItem)
                     {
                        object.harvestItem = giftObj.harvestItem;
                     }
                     object.levelString = Global.farmGameSettingsManager.getFarmItemByName(object.name).friendlyName;
                     friendlyName = object.localizedName.toString();
                     if(this.m_searchString == "" || friendlyName.toLowerCase().search(this.m_searchString) != -1)
                     {
                        m_data.push(object);
                     }
                  }
                  else
                  {
                     m_usedTypes[giftObj.code] += giftNum;
                  }
               }
            }
            m_data.sortOn("count",[Array.NUMERIC | Array.DESCENDING]);
         }
         fixArrows();
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var mc:MovieClip = null;
         var dropItem:FarmItem = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            mc = m_tiles[compId] as MovieClip;
            dropItem = Global.farmGameSettingsManager.getFarmItemByName(m_data[index + compId].harvestItem);
            m_tiles[compId].visible = true;
            this.hideChickenCoopTileUIElements(compId);
            if(m_usedTypes[m_data[index + compId].code] <= 0)
            {
               this.setupDisabledChickenCoopTileLayout(compId,index,dropItem);
            }
            else
            {
               this.setupActiveChickenCoopTileLayout(compId,index,dropItem);
            }
            addIcon(m_data[index + compId].name,"icon",m_tiles[compId],m_tiles[compId].icon);
            if(!m_toolTips[compId])
            {
               m_toolTips[compId] = new ToolTip();
               m_toolTips[compId].attachToolTip(m_tiles[compId].icon);
            }
            else
            {
               m_toolTips[compId].detachToolTip(m_tiles[compId].icon);
               m_toolTips[compId].attachToolTip(m_tiles[compId].icon);
            }
            m_toolTips[compId].toolTip = "";
            if(ZLocUtils.hasString("Dialogs",m_data[index + compId].name + "_toolTip"))
            {
               m_toolTips[compId].toolTip = ZLocUtils.t("Dialogs",m_data[index + compId].name + "_toolTip");
            }
            if(dropItem)
            {
               addIcon(dropItem.name,"icon2",m_tiles[compId],m_tiles[compId].icon2,75,75);
            }
            else
            {
               ErrorManager.addError("harvestItem \'" + m_data[index + compId].harvestItem + "\' is invalid");
            }
         }
      }
      
      protected function hideChickenCoopTileUIElements(compId:int) : void
      {
         m_tiles[compId].level_tf.visible = false;
         m_tiles[compId].grayLevel_tf.visible = false;
         m_tiles[compId].yield_tf.visible = false;
         m_tiles[compId].grayYield_tf.visible = false;
         m_tiles[compId].growth_tf.visible = false;
         m_tiles[compId].grayGrowth_tf.visible = false;
         m_tiles[compId].use_bt.visible = false;
         m_tiles[compId].useGray_bt.visible = false;
         m_tiles[compId].giftAmount_tf.visible = false;
         m_tiles[compId].grayGiftAmount_tf.visible = false;
         m_tiles[compId].eggText1_tf.visible = false;
         m_tiles[compId].grayEggText1_tf.visible = false;
         m_tiles[compId].eggText2_tf.visible = false;
         m_tiles[compId].grayEggText2_tf.visible = false;
         m_tiles[compId].brownBKG_mc.visible = false;
         m_tiles[compId].lightBKG_mc.visible = false;
         m_tiles[compId].whiteBKG_mc.visible = false;
      }
      
      protected function setupDisabledChickenCoopTileLayout(compId:int, index:int = 0, item:FarmItem = null) : void
      {
         var str:String = null;
         var strs:Array = null;
         m_tiles[compId].grayLevel_tf.visible = true;
         m_tiles[compId].grayLevel_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].levelString);
         if(m_data[index + compId].coinYield)
         {
            if(m_data[index + compId].coinYield.toString() != "")
            {
               m_tiles[compId].grayYield_tf.visible = true;
               m_tiles[compId].grayYield_tf.text = ZLocUtils.t("Dialogs","EggYield",{
                  "coinQuantity":m_data[index + compId].coinYield,
                  "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",m_data[index + compId].coinYield)
               });
            }
         }
         if(m_data[index + compId].harvestTime)
         {
            if(m_data[index + compId].harvestTime.toString() != "")
            {
               m_tiles[compId].grayGrowth_tf.visible = true;
               m_tiles[compId].grayGrowth_tf.text = ZLocUtils.t("Dialogs","GrowthDays",{
                  "quantity":m_data[index + compId].harvestTime,
                  "Day_word":ZLocUtils.tk("Dialogs","Day_word","",m_data[index + compId].harvestTime)
               });
            }
         }
         m_tiles[compId].grayGiftAmount_tf.visible = true;
         m_tiles[compId].grayGiftAmount_tf.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":m_usedTypes[m_data[index + compId].code]});
         if(null == item)
         {
            str = ZLocUtils.t("Dialogs","ChickensLay",{"itemA":ZLocUtils.tk_pk(m_data[index + compId].localizedName)});
            strs = ZLocUtils.splitString(str,2);
            if(1 <= strs.length)
            {
               m_tiles[compId].grayEggText1_tf.visible = true;
               m_tiles[compId].grayEggText1_tf.text = strs[0];
               if(2 == strs.length)
               {
                  m_tiles[compId].grayEggText2_tf.visible = true;
                  m_tiles[compId].grayEggText2_tf.text = strs[1];
               }
            }
         }
         else
         {
            str = ZLocUtils.t("Dialogs","EggDrop",{
               "itemA":ZLocUtils.tk_pk(m_data[index + compId].localizedName),
               "itemB":ZLocUtils.tk_pk(item.friendlyName)
            });
            strs = ZLocUtils.splitString(str,2);
            if(1 <= strs.length)
            {
               m_tiles[compId].grayEggText1_tf.visible = true;
               m_tiles[compId].grayEggText1_tf.text = strs[0];
               if(2 == strs.length)
               {
                  m_tiles[compId].grayEggText2_tf.visible = true;
                  m_tiles[compId].grayEggText2_tf.text = strs[1];
               }
            }
         }
         m_tiles[compId].useGray_bt.visible = true;
         if(m_buttons[compId])
         {
            m_buttons[compId].disabled = true;
         }
      }
      
      protected function setupActiveChickenCoopTileLayout(compId:int, index:int = 0, item:FarmItem = null) : void
      {
         var str:String = null;
         var strs:Array = null;
         m_tiles[compId].brownBKG_mc.visible = true;
         m_tiles[compId].lightBKG_mc.visible = true;
         m_tiles[compId].whiteBKG_mc.visible = true;
         m_tiles[compId].level_tf.visible = true;
         m_tiles[compId].level_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].levelString);
         if(m_data[index + compId].coinYield)
         {
            if(m_data[index + compId].coinYield.toString() != "")
            {
               m_tiles[compId].yield_tf.visible = true;
               m_tiles[compId].yield_tf.text = ZLocUtils.t("Dialogs","EggYield",{
                  "coinQuantity":m_data[index + compId].coinYield,
                  "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",m_data[index + compId].coinYield)
               });
            }
         }
         if(m_data[index + compId].harvestTime)
         {
            if(m_data[index + compId].harvestTime.toString() != "")
            {
               m_tiles[compId].growth_tf.visible = true;
               m_tiles[compId].growth_tf.text = ZLocUtils.t("Dialogs","GrowthDays",{
                  "quantity":m_data[index + compId].harvestTime,
                  "Day_word":ZLocUtils.tk("Dialogs","Day_word","",m_data[index + compId].harvestTime)
               });
            }
         }
         m_tiles[compId].giftAmount_tf.visible = true;
         m_tiles[compId].giftAmount_tf.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":m_usedTypes[m_data[index + compId].code]});
         if(null == item)
         {
            str = ZLocUtils.t("Dialogs","ChickensLay",{"itemA":ZLocUtils.tk_pk(m_data[index + compId].localizedName)});
            strs = ZLocUtils.splitString(str,2);
            if(1 <= strs.length)
            {
               m_tiles[compId].eggText1_tf.visible = true;
               m_tiles[compId].eggText1_tf.text = strs[0];
               if(2 == strs.length)
               {
                  m_tiles[compId].eggText2_tf.visible = true;
                  m_tiles[compId].eggText2_tf.text = strs[1];
               }
            }
         }
         else
         {
            str = ZLocUtils.t("Dialogs","EggDrop",{
               "itemA":ZLocUtils.tk_pk(m_data[index + compId].localizedName),
               "itemB":ZLocUtils.tk_pk(item.friendlyName)
            });
            strs = ZLocUtils.splitString(str,2);
            if(1 <= strs.length)
            {
               m_tiles[compId].eggText1_tf.visible = true;
               m_tiles[compId].eggText1_tf.text = strs[0];
               if(2 == strs.length)
               {
                  m_tiles[compId].eggText2_tf.visible = true;
                  m_tiles[compId].eggText2_tf.text = strs[1];
               }
            }
         }
         m_tiles[compId].use_bt.visible = true;
         m_buttons[compId] = new GenericButton(m_tiles[compId].use_bt,onUse);
         m_buttons[compId].m_overlay.name = m_data[index + compId].name;
         m_buttons[compId].text = ZLocUtils.t("Dialogs","Remove");
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         var msg:String = null;
         if(m_howDoesThisWorkPopup == null)
         {
            msg = ZLocUtils.t("Dialogs","ChickenCoopBuildingHowDoesThisWork");
            m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET_LRG);
            m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(m_howDoesThisWorkPopup,false,"howDoesThisWorkPopup",true);
         }
      }
   }
}

