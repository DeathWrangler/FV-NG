package GameMode
{
   import Classes.AmexSocialCurrencyWindmillBuilding;
   import Classes.AmsterdamInnovationBonus;
   import Classes.AntiqueMuseumDeco;
   import Classes.AntiqueMuseumV2Deco;
   import Classes.AntiqueMuseumV2HarvestBuilding;
   import Classes.BoatRushBuildingMapTrigger;
   import Classes.BoraBoraInnovationBuildingRewards;
   import Classes.BoraboraRotateableDecoration;
   import Classes.BuffDecoration;
   import Classes.BuildingDecoration;
   import Classes.CanadaInnovationExpert;
   import Classes.CanadaInnovationMaster;
   import Classes.CanadaInnovationNovice;
   import Classes.Combine;
   import Classes.CraftRewardGnome;
   import Classes.Dec19InnovationBonus;
   import Classes.DecoAvatarAction;
   import Classes.Decoration;
   import Classes.DynamicMasterySign;
   import Classes.EnglandUnwitherClock;
   import Classes.EvolutionAnimalCrate;
   import Classes.FMAirship;
   import Classes.FarmGameObject;
   import Classes.FarmersMarketBonusRewardMapTrigger;
   import Classes.FishingV2Collection;
   import Classes.FishingV2Mastery;
   import Classes.FlowerDecoration;
   import Classes.GateDecoration;
   import Classes.Gnome;
   import Classes.GuildEventBonus;
   import Classes.HaitiRewardDecoration;
   import Classes.Halloween2019InnovationExpert;
   import Classes.Halloween2019InnovationMaster;
   import Classes.Halloween2019InnovationNovice;
   import Classes.HalloweenBonus;
   import Classes.HalloweenInnovationGhoulDecoration;
   import Classes.Harvester;
   import Classes.InteractiveDecoration;
   import Classes.IsraelInnovationBonus;
   import Classes.LockedBox;
   import Classes.LootableDecoration;
   import Classes.LootableDecorationMysteryItem;
   import Classes.MapResource;
   import Classes.MaskedDecoration;
   import Classes.MasteryBuffDecoration;
   import Classes.MiniGameDecoration;
   import Classes.MysteryGift;
   import Classes.NPCDecoration;
   import Classes.OctoberSidecarFeatureBonusBuilding;
   import Classes.PartyBuilding;
   import Classes.PermanentBuffDecoration;
   import Classes.PlotRemover;
   import Classes.RTUEMysteryGift;
   import Classes.RecipeMasterySign;
   import Classes.RotatableCombine;
   import Classes.RotatableHarvester;
   import Classes.RotatableOrchardHarvester;
   import Classes.RotatablePlotRemover;
   import Classes.RotatableSeeder;
   import Classes.RotatableTractor;
   import Classes.RotateableDecoration;
   import Classes.RussiaInnovationBonus;
   import Classes.Seeder;
   import Classes.SocialPlumbingMysteryGift;
   import Classes.SouthindiaInnovationBonus;
   import Classes.StaticDecoration;
   import Classes.StencilDecoration;
   import Classes.StorageBuilding;
   import Classes.SuperEnabledMasterySign;
   import Classes.SwapDecoration;
   import Classes.Tractor;
   import Classes.TropicalMarketBonusRewardMapTrigger;
   import Classes.TurtleInnovationDecoration;
   import Classes.TuscanyInnovationBonus;
   import Classes.UGCDecoration;
   import Classes.ValentinesPresent;
   import Classes.VisgothDecoration;
   import Classes.VotingDecoration;
   import Classes.WinterRacingMapTrigger;
   import Classes.WreathFestivalInnovationBonus;
   import Classes.XMASInnovationDeco;
   import Classes.ZItem.BuffItem;
   import Classes.ZItem.DecorationItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Transactions.TBoraboraDecorationPlace;
   import Transactions.TDecorationPlace;
   import Transactions.TGetObjectPlaceRewardLink;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class GMDecorationPlace extends GMObjectMove
   {
      
      private static var m_soundLoaded:Boolean = false;
      
      private var m_decorationType:String;
      
      private var m_itemToShare:XML;
      
      private var m_item:FarmItem;
      
      private var m_buffMessage:GenericDialog;
      
      private var m_decorationTypes:Array = [AmexSocialCurrencyWindmillBuilding,MiniGameDecoration,RotateableDecoration,MaskedDecoration,LootableDecoration,LootableDecorationMysteryItem,InteractiveDecoration,StaticDecoration,PartyBuilding,GateDecoration,RecipeMasterySign,Tractor,Harvester,Seeder,Combine,PlotRemover,FlowerDecoration,Decoration,MysteryGift,SocialPlumbingMysteryGift,RTUEMysteryGift,ValentinesPresent,LockedBox,CraftRewardGnome,HaitiRewardDecoration,FMAirship,BuffDecoration,EnglandUnwitherClock,VisgothDecoration,BuildingDecoration,MasteryBuffDecoration,PermanentBuffDecoration,SuperEnabledMasterySign,DynamicMasterySign,VotingDecoration,AntiqueMuseumDeco,NPCDecoration,SwapDecoration,Gnome,UGCDecoration,EvolutionAnimalCrate,DecoAvatarAction,StencilDecoration,XMASInnovationDeco,TurtleInnovationDecoration,HalloweenBonus,TuscanyInnovationBonus,FishingV2Mastery,FishingV2Collection,RussiaInnovationBonus,IsraelInnovationBonus,SouthindiaInnovationBonus,Dec19InnovationBonus,HalloweenInnovationGhoulDecoration
      ,GuildEventBonus,RotatableTractor,RotatableSeeder,RotatableHarvester,RotatableCombine,RotatableOrchardHarvester,RotatablePlotRemover,Halloween2019InnovationNovice,Halloween2019InnovationExpert,Halloween2019InnovationMaster,WinterRacingMapTrigger,FarmersMarketBonusRewardMapTrigger,AmsterdamInnovationBonus,BoraboraRotateableDecoration,BoraBoraInnovationBuildingRewards,AntiqueMuseumV2Deco,AntiqueMuseumV2HarvestBuilding,CanadaInnovationNovice,CanadaInnovationExpert,CanadaInnovationExpert,CanadaInnovationMaster,BoatRushBuildingMapTrigger,OctoberSidecarFeatureBonusBuilding,TropicalMarketBonusRewardMapTrigger,WreathFestivalInnovationBonus];
      
      public function GMDecorationPlace(decorationType:String, isGift:Boolean = false, buildingId:Number = 0, shouldReOpenGift:Boolean = true, currency:String = "")
      {
         if(!m_soundLoaded)
         {
            SoundManager.addSound("decorate",Global.getAssetURL("assets/sounds/actions/sfx_drop_decoration.mp3"),false);
            m_soundLoaded = true;
         }
         m_cid = buildingId;
         this.m_decorationType = decorationType;
         m_isGift = isGift;
         m_storedOrigin = buildingId;
         super(null,null,isGift,shouldReOpenGift,false,currency);
         if(Global.flashHotParams["MP_SELECTED_INITIALIZED_ON_CONSTRUCTOR"])
         {
            this.createSelectedObject();
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_decorationType);
         if(item.className == "BuffDecoration")
         {
            this.showBuffMessage();
         }
      }
      
      public function get decorationType() : String
      {
         return this.m_decorationType;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!Global.flashHotParams["MP_SELECTED_INITIALIZED_ON_CONSTRUCTOR"])
         {
            this.createSelectedObject();
         }
         return super.onMouseMove(event);
      }
      
      protected function createSelectedObject() : void
      {
         var tempClass:Class = null;
         var item:FarmItem = null;
         if(!m_selectedObject)
         {
            m_highlightedPoint = getMouseTilePos();
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_decorationType);
            if(item.className != "")
            {
               tempClass = getDefinitionByName("Classes." + item.className) as Class;
            }
            else
            {
               tempClass = getDefinitionByName("Classes.Decoration") as Class;
            }
            this.setSelectedObject(tempClass);
            if(m_selectedObject.canBeSurfaced())
            {
               FeatureBuildingSurfacingManager.getInstance().highlightBuildings(m_selectedObject as MapResource,true);
            }
         }
      }
      
      protected function setSelectedObject(itemClass:Class) : void
      {
         var decoration:Decoration = new itemClass(this.m_decorationType);
         decoration.setPlaced(false);
         decoration.setOuter(Global.world);
         decoration.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
         m_selectedObject = decoration as FarmGameObject;
      }
      
      public function bypassBuy() : Boolean
      {
         return false;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var isInDataSourceExperiment:Boolean = false;
         var hasItemContent:Boolean = false;
         var farmItem:FarmItem = null;
         var itemCode:String = null;
         var item:XML = null;
         var subtype:String = null;
         var itemActionBundle:String = null;
         var showFeed:Boolean = false;
         var code:String = null;
         var hasMinXpAndMaxPercentXp:Boolean = false;
         var minXp:int = 0;
         var maxPercentXp:Number = NaN;
         var actionBundle:String = null;
         var images:Array = null;
         var iconImages:Array = null;
         var imageArr:Array = null;
         var imageArrLen:int = 0;
         var curDS:BaseDataSource = null;
         var imageName:String = null;
         var i:int = 0;
         var xmlImages:XMLList = null;
         var xmlIdx:int = 0;
         var currentLevel:int = 0;
         var nextLevel:int = 0;
         var currentLevelXml:XML = null;
         var nextLevelXml:XML = null;
         var xpDiff:int = 0;
         var xpBonus:int = 0;
         var extraData:Object = null;
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            if(Global.world.checkNumObjectLimit())
            {
               isInDataSourceExperiment = FarmGameSettingsManager.isInDataSourceExperiment();
               hasItemContent = true;
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_decorationType);
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_decorationType);
               if(!isInDataSourceExperiment)
               {
                  item = farmItem.xml;
                  if(!item)
                  {
                     hasItemContent = false;
                  }
               }
               if(hasItemContent && m_isGift == false && m_cid == 0)
               {
                  if(this.bypassBuy() || Global.player.tryBuy(m_selectedObject as MapResource,m_isGift,null,0,"",m_currency))
                  {
                     if(isInDataSourceExperiment)
                     {
                        actionBundle = farmItem.getStringFromDataSource("actionBundle");
                     }
                     else
                     {
                        actionBundle = item.@actionBundle.toString();
                     }
                     if(actionBundle != "")
                     {
                        images = [];
                        if(isInDataSourceExperiment)
                        {
                           iconImages = [];
                           imageArr = farmItem.getArrayFromDataSource("image");
                           imageArrLen = int(imageArr.length);
                           for(i = 0; i < imageArrLen; i++)
                           {
                              curDS = imageArr[i] as BaseDataSource;
                              imageName = curDS.getString("name");
                              if(imageName == "newsfeed")
                              {
                                 images.push({
                                    "src":Global.getAssetURL(curDS.getString("url")),
                                    "href":"{SN_APP_URL}{creative:picture}index.php"
                                 });
                              }
                              else if(imageName == "icon")
                              {
                                 iconImages.push({
                                    "src":Global.getAssetURL(curDS.getString("url")),
                                    "href":"{SN_APP_URL}{creative:picture}index.php"
                                 });
                              }
                           }
                           if(images.length < 1 && iconImages.length > 0)
                           {
                              images = iconImages;
                           }
                        }
                        else
                        {
                           xmlImages = item.image.(@name == "newsfeed");
                           if(Boolean(xmlImages) && Boolean(xmlImages.length()))
                           {
                              for(xmlIdx = 0; xmlIdx < xmlImages.length(); xmlIdx++)
                              {
                                 images.push({
                                    "src":Global.getAssetURL(xmlImages[xmlIdx].@url),
                                    "href":"{SN_APP_URL}{creative:picture}index.php"
                                 });
                              }
                           }
                           else
                           {
                              xmlImages = item.image.(@name == "icon");
                              if(xmlImages.length())
                              {
                                 images.push({
                                    "src":Global.getAssetURL(xmlImages[0].@url),
                                    "href":"{SN_APP_URL}{creative:picture}index.php"
                                 });
                              }
                           }
                        }
                     }
                  }
               }
               if(isInDataSourceExperiment)
               {
                  showFeed = farmItem.showFeed;
                  code = farmItem.code;
                  hasMinXpAndMaxPercentXp = farmItem.hasPropertyInDataSource("minXp") && farmItem.hasPropertyInDataSource("maxPercentXp");
                  minXp = farmItem.getIntFromDataSource("minXp");
                  maxPercentXp = farmItem.getNumberFromDataSource("maxPercentXp");
               }
               else
               {
                  showFeed = item.@showFeed == "true";
                  code = item.@code;
                  hasMinXpAndMaxPercentXp = item.minXp.toString() != "" && item.maxPercentXp.toString() != "";
                  minXp = int(item.minXp);
                  maxPercentXp = Number(item.maxPercentXp);
               }
               if(showFeed)
               {
                  if(!Global.player.getSeenFlag("seenFeedForItem" + code))
                  {
                     Global.player.setSeenFlag("seenFeedForItem" + code,true);
                     this.showShareItemDialog(farmItem);
                  }
               }
               if(hasMinXpAndMaxPercentXp && m_cid == Global.world.GIFTBOX_ID)
               {
                  currentLevel = Global.player.level;
                  nextLevel = currentLevel + 1;
                  currentLevelXml = Global.farmGameSettingsManager.getLevelXML(currentLevel);
                  nextLevelXml = Global.farmGameSettingsManager.getLevelXML(nextLevel);
                  if(Boolean(currentLevelXml) && Boolean(nextLevelXml))
                  {
                     xpDiff = nextLevelXml.@requiredXP - currentLevelXml.@requiredXP;
                     xpDiff *= maxPercentXp / 100;
                     xpBonus = Math.max(xpDiff,minXp);
                     xpBonus = Global.player.calculateAndAddXp(xpBonus);
                     m_selectedObject.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":xpBonus}));
                  }
               }
               if(canMultiPlace())
               {
                  extraData = new Object();
                  extraData.isGift = m_isGift;
                  if(m_isGift)
                  {
                     if(Global.player.getGiftCountForItemKey(itemCode) > 1)
                     {
                        farmItem.onUse(m_cid,extraData);
                     }
                     else
                     {
                        Global.world.setDefaultGameMode();
                     }
                  }
                  else if(m_cid == 0)
                  {
                     Global.world.addGameMode(new GMDecorationPlace(this.m_decorationType,false,0,true,this.m_currency));
                  }
                  else if(m_cid < 0 && Global.player.hasInventoryItem(itemCode,m_cid))
                  {
                     farmItem.onUse(m_cid,extraData);
                  }
                  else if(m_cid > 0 && StorageBuilding(Global.world.getObjectById(m_cid)).contents[itemCode] > 0)
                  {
                     farmItem.onUse(m_cid,extraData);
                  }
                  else
                  {
                     Global.world.setDefaultGameMode();
                  }
               }
               else
               {
                  Global.world.setDefaultGameMode();
               }
               if(m_selectedObject.getClassName() == "BoraboraRotateableDecoration")
               {
                  m_selectedObject.addTransaction(new TBoraboraDecorationPlace(m_selectedObject as Decoration,m_isGift,m_storedOrigin,m_currency));
               }
               else
               {
                  m_selectedObject.addTransaction(new TDecorationPlace(m_selectedObject as Decoration,m_isGift,m_storedOrigin,m_currency));
               }
               (m_selectedObject as Decoration).setPlaced(true);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
               Global.world.addGameMode(this);
            }
         }
         return true;
      }
      
      private function showShareItemDialog(item:FarmItem) : void
      {
         var message:GenericPopup = null;
         if(item != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_itemToShare = null;
               this.m_item = item;
            }
            else
            {
               this.m_itemToShare = item.xml ? item.xml : (item.cashXML ? item.cashXML : item.saleXML);
            }
            message = new GenericIconPopup(ZLocUtils.t("Dialogs","Share" + item.actionBundle),GenericPopup.TYPE_SHARECANCEL,this.onConfirmShareItem,item.icon,false,true,"",true);
            UI.displayPopup(message);
            FarmStatsManager.count("feed",item.name,"prompt");
         }
      }
      
      private function onConfirmShareItem(event:GenericPopupEvent) : void
      {
         var generateRewardFee:String = null;
         var name:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            if(this.m_item)
            {
               generateRewardFee = this.m_item.getPropertyFromItemCashSaleSource("generateRewardFeed");
               name = this.m_item.getPropertyFromItemCashSaleSource("name");
            }
            else
            {
               generateRewardFee = this.m_itemToShare.@generateRewardFeed;
               name = this.m_itemToShare.@name;
            }
            if(generateRewardFee == "true")
            {
               TransactionManager.addTransaction(new TGetObjectPlaceRewardLink(name,this.onShareAcceptCallback),true);
            }
            else
            {
               this.onShareAcceptCallback();
            }
         }
         else if(this.m_item)
         {
            FarmStatsManager.count(this.m_item.name + "Permission","dontAllowFeed");
            FarmStatsManager.count("feed",this.m_item.name,"cancel");
         }
         else
         {
            FarmStatsManager.count(this.m_itemToShare.@name + "Permission","dontAllowFeed");
            FarmStatsManager.count("feed",this.m_itemToShare.@name,"cancel");
         }
      }
      
      private function onShareAcceptCallback(rewardUrl:String = "") : void
      {
         var item:FarmItem = null;
         var bundleData:Object = null;
         if(this.m_item)
         {
            item = this.m_item;
         }
         else
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemToShare.@name);
         }
         if(item != null)
         {
            bundleData = {
               "item_name":item.friendlyName,
               "images":[{
                  "href":"{SN_APP_URL}{creative:picture}index.php",
                  "src":item.newsfeed
               }]
            };
            if(rewardUrl != "")
            {
               bundleData.images = [{
                  "href":"{SN_APP_URL}" + rewardUrl,
                  "src":item.newsfeed
               }];
               bundleData.reward_link = rewardUrl;
            }
            if(this.m_item)
            {
               GlobalEngine.socialNetwork.publishFeedStory(this.m_item.actionBundle,bundleData,[],false);
               FarmStatsManager.count(this.m_item.name + "Permission","allowFeed");
               FarmStatsManager.count("feed",this.m_item.name,"share");
            }
            else
            {
               GlobalEngine.socialNetwork.publishFeedStory(this.m_itemToShare.@actionBundle,bundleData,[],false);
               FarmStatsManager.count(this.m_itemToShare.@name + "Permission","allowFeed");
               FarmStatsManager.count("feed",this.m_itemToShare.@name,"share");
            }
         }
      }
      
      private function showBuffMessage() : void
      {
         var decoration:DecorationItem = null;
         var buffItemName:String = null;
         var buffItem:BuffItem = null;
         var config:GenericDialogConfig = null;
         var buffMessageKey:String = this.m_decorationType + "_UseConfirmationBody";
         if(ZLocUtils.hasString("Dialogs",buffMessageKey))
         {
            decoration = Global.farmGameSettingsManager.getFarmItemByName(this.m_decorationType) as DecorationItem;
            if(decoration)
            {
               buffItemName = decoration.buffName;
               if(buffItemName)
               {
                  buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName) as BuffItem;
                  if(buffItem)
                  {
                     config = new GenericDialogConfig();
                     config.setBodyText(ZLocUtils.t("Dialogs",buffMessageKey,{"timeStr":FarmGameUtil.toFriendlyTime(buffItem.buffExpires)}));
                     config.setTitleText(ZLocUtils.t("Dialogs",this.m_decorationType + "_UseConfirmationTitle"));
                     config.showCloseButton(false);
                     config.setName("BuffMessage");
                     config.addButton(ZLocUtils.t("FarmGame","PlaceNow"),GenericDialogConfig.COLOR_GREEN);
                     config.addButton(ZLocUtils.t("Dialogs","Cancel"),GenericDialogConfig.COLOR_RED,this.onBuffMessageCancel);
                     this.m_buffMessage = GenericDialog.createFromConfig(config);
                     if(this.m_buffMessage)
                     {
                        this.m_buffMessage.show(false);
                     }
                  }
               }
            }
         }
      }
      
      private function onBuffMessageCancel(isAccept:Boolean) : void
      {
         Global.world.removeGameMode(this);
         Global.world.setDefaultGameMode();
         if(this.m_buffMessage)
         {
            this.m_buffMessage.destroy();
         }
         UI.displayGiftBoxWindow();
      }
   }
}

