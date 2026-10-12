package Transactions
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.CrossPromoConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.ToasterIconPaths;
   import Classes.Constants.WorldsConstants;
   import Classes.ExtendedPermissionState;
   import Classes.Growable.GrowableInstanceDataProxy;
   import Classes.NPCConfigData;
   import Classes.Plot;
   import Classes.Tractor;
   import Classes.TutController;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmLoadPhaseMonitor;
   import Classes.util.ZLocUtils;
   import Display.DailyLottery;
   import Display.FarmDynamicDialog;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.MysteryBoxBalloonDialog;
   import Display.UI;
   import Display.WishlistNotifyPopup;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import Init.PostInit.DoCreateNewAvatar;
   import Init.PostInitActionHandlers.PostInitPopup;
   import Init.PostInitActionHandlers.PostInitToaster;
   import Init.PostInitActionHandlers.UnlockExpansionWorldAction;
   import Managers.ChatManager;
   import Managers.CollectionsManager;
   import Managers.DoobersManager;
   import Managers.EmailManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.FreezeManager;
   import Managers.InGamePaymentsManager;
   import Managers.InstanceDataStoreManager;
   import Managers.ItemBuffManager;
   import Managers.LESetManager;
   import Managers.LicenseManager;
   import Managers.LimitedSaleUtility;
   import Managers.MessageManager;
   import Managers.NPCManager;
   import Managers.PackPurchaseManager;
   import Managers.SocialActionsManager;
   import Managers.SystemNotificationManager;
   import Managers.VotingDataManager;
   import Managers.ZoomManager;
   import Widgets.Windows.GiftBox.GiftBoxWindow;
   import Widgets.Windows.IconToasterWindow;
   import Widgets.Windows.PackPurchasedToaster;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.system.Security;
   
   public class TInitUser extends TFarmTransaction
   {
      
      private static const STAT_SAMPLE_ZLOC_FAIL_RUNTIME_PARAM:String = "STAT_SAMPLE_ZLOC_FAIL";
      
      private static var m_worldToLoad:Object = null;
      
      protected var m_firstName:String;
      
      private var m_timezoneOffset:Number;
      
      private const NUM_SEEN_EXPAND_FARM:int = 2;
      
      private const SHOW_EXPAND_FARM_SIZE:int = 14;
      
      private const SHOW_EXPAND_MIN_LEVEL:int = 4;
      
      private const PROMO_VISIBILITY_NONE:String = "none";
      
      private const PROMO_VISIBILITY_FANS:String = "fans";
      
      private const PROMO_VISIBILITY_ALL:String = "all";
      
      private const PROMO_TYPE_ENTER_GAME_MSG:String = "entergamemsg";
      
      private const PROMO_TYPE_HUD_ICON:String = "icon";
      
      private const PROMO_MOTD_SEEN_FLAG:String = "cross_gifting_MOTD_75";
      
      private const NOT_PAYER:int = -1;
      
      private const DIALOG_SUPPRESS_NONE:int = 0;
      
      private const DIALOG_SUPPRESS_ALL:int = 1;
      
      private var m_bookmarkCash:int = 0;
      
      private var m_wishSenders:Array;
      
      private var m_wishRewardLink:String;
      
      private var m_wishName:String;
      
      private var m_wishImage:String;
      
      public function TInitUser(firstName:String)
      {
         super();
         this.m_firstName = firstName;
         this.m_timezoneOffset = this.getTimezoneOffset();
      }
      
      public static function worldToLoad(world:Object) : void
      {
         m_worldToLoad = world;
      }
      
      override public function isInitTransaction() : Boolean
      {
         return true;
      }
      
      override public function perform() : void
      {
         var needsToLoadWorld:Boolean = null == m_worldToLoad;
         var flashControllerInit:String = GlobalEngine.getFlashVar(Global.loadingMetricsRecorder.KEY_LOADTIME_FLASHCONTROLLER) as String;
         Global.loadingMetricsRecorder.addTimingMetric(Global.loadingMetricsRecorder.KEY_LOADTIME_FLASHCONTROLLER,flashControllerInit);
         signedCall("UserService.initUser",this.m_firstName,this.m_timezoneOffset,needsToLoadWorld,false,flashControllerInit);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var userLocale:String = null;
         var initUserStartTimeMetric:String = null;
         var socialActions:Object = null;
         var staticSystemNotifications:Object = null;
         var dynamicSystemNotifications:Object = null;
         var suppressDialogs:int = 0;
         var qaPopupBlock:Boolean = false;
         var initUserstartTime:String = null;
         var systemNotificationManager:SystemNotificationManager = null;
         var neighbors:String = null;
         var npcNeighbors:Array = null;
         var bumperCropPaid:Object = null;
         var firstDay:Boolean = false;
         var friendUnwithered:Number = NaN;
         var reactivating:String = null;
         var freeGamePopupGate:int = 0;
         var userFreeGamePopupVersion:int = 0;
         var userPayerPopupGate:int = 0;
         var userPayerPopupVersion:int = 0;
         var userSetPayerPopupEligibile:Boolean = false;
         var freeGameLevelLock:Boolean = false;
         var userInfo:Object = null;
         var shouldLoadWorld:Boolean = false;
         var worldId:String = null;
         var plots:Array = null;
         var plot:Plot = null;
         var plotIdx:int = 0;
         var rsvpResult:Object = null;
         var rsvpStatus:Object = null;
         var rsvpKey:String = null;
         var newKey:String = null;
         var licensedItemCode:String = null;
         var packId:String = null;
         var key:String = null;
         var featureName:String = null;
         var avatar:FarmAvatar = null;
         var buffX:String = null;
         var storageData:Object = null;
         var itemCode:String = null;
         var giftData:Array = null;
         var messageTitle:String = null;
         var messageText:String = null;
         var incrementalGateItem:Object = null;
         var acquired:Object = null;
         var code:String = null;
         var gateItem:FarmItem = null;
         var count:* = 0;
         var npcData:Object = null;
         var expansionData:ExpansionData = null;
         var forallAccess:ExpansionAccess = null;
         if(result != null)
         {
            userLocale = "";
            if(result["locale"])
            {
               userLocale = result["locale"];
            }
            if(result["flashHotParams"] != null)
            {
               Global.flashHotParams = result["flashHotParams"];
            }
            initUserStartTimeMetric = Global.loadingMetricsRecorder.KEY_LOADTIME_INITUSER;
            if(result[initUserStartTimeMetric] != null)
            {
               initUserstartTime = new String(result[initUserStartTimeMetric]);
               Global.loadingMetricsRecorder.addTimingMetric(initUserStartTimeMetric,initUserstartTime);
            }
            if(Global.flashHotParams.hasOwnProperty(STAT_SAMPLE_ZLOC_FAIL_RUNTIME_PARAM))
            {
               ZLocUtils.setErrorStatSampleRate(Global.flashHotParams[STAT_SAMPLE_ZLOC_FAIL_RUNTIME_PARAM]);
            }
            if(result["promos"] != null)
            {
               Global.player.populatePromos(result["promos"]);
            }
            socialActions = null;
            if(result["socialActions"] != null)
            {
               socialActions = result.socialActions;
            }
            if(result["3rdPartyID"] != null)
            {
               Global.player.thirdPartyID = result["3rdPartyID"];
            }
            TransactionManager.setSequenceID(result.sequenceId);
            Global.player.extendedPermissionState = new ExtendedPermissionState(result["snExtendedPermissions"]);
            staticSystemNotifications = result["systemNotifications"];
            dynamicSystemNotifications = result["dynamicSystemNotifications"];
            if(Boolean(staticSystemNotifications) || Boolean(dynamicSystemNotifications))
            {
               systemNotificationManager = SystemNotificationManager.getInstance();
               systemNotificationManager.load(staticSystemNotifications,dynamicSystemNotifications);
               systemNotificationManager.displayPendingNotifications();
            }
            if(result["hasValidUnwitherClock"] == 1)
            {
               Global.world.growAllPlots();
            }
            if(result["errorPopupEnabled"] != null && Boolean(result["errorPopupEnabled"]))
            {
               Global.errorPopupEnabled = true;
            }
            if(result.hasOwnProperty("isRegiftOptionAvailable"))
            {
               GiftBoxWindow.isReGiftOptionAvailable = result.isRegiftOptionAvailable;
            }
            suppressDialogs = this.DIALOG_SUPPRESS_NONE;
            qaPopupBlock = false;
            if(Boolean(result.userInfo.player.isAQA) && Boolean("1" == result.userInfo.player.isAQA) || Global.toolMode)
            {
               Global.player.setIsAutomatedQA(true);
            }
            if(Boolean(result.userInfo.player.isAKeynoteUser) && "1" == result.userInfo.player.isAKeynoteUser)
            {
               Global.player.setIsKeynoteQA(true);
            }
            if(result.isEligibleForNoPopup)
            {
               Global.nopopupManager.setIsEligibleForNoPopups(true);
            }
            else
            {
               Global.nopopupManager.setIsEligibleForNoPopups(false);
            }
            if(Global.suppressAllInitUserDialogs)
            {
               UI.stopPopups(true);
               qaPopupBlock = true;
               suppressDialogs = this.DIALOG_SUPPRESS_ALL;
            }
            if(Global.world != null && Global.player != null)
            {
               neighbors = result.neighbors;
               npcNeighbors = result.npcs;
               Global.pendingPresents = result.pendingPresents;
               bumperCropPaid = result.bumperCropPaid;
               firstDay = Boolean(result.firstDay);
               friendUnwithered = Number(result.friendUnwithered);
               this.m_wishSenders = result.wishData["wishSenders"];
               this.m_wishRewardLink = result.wishData["wishRewardLink"];
               this.m_wishName = result.wishData["wishName"];
               this.m_wishImage = result.wishData["wishImage"];
               if(result["geoip"])
               {
                  Global.geoIpManager.geoip = result["geoip"];
               }
               Global.player.purchaseHistory = result["purchaseHistory"];
               if(!Global.experimentManager.initialized)
               {
                  Global.experimentManager.loadServerVariants(result.experiments);
               }
               Global.postInitSettings.initUserResult = result;
               Global.hud.postExperimentsLoadedInit();
               reactivating = result.reactivating;
               Global.player.daysInactive = result.hasOwnProperty("daysInactive") ? int(result.daysInactive) : 0;
               if(reactivating != null && reactivating != "")
               {
                  Global.player.reactivating = true;
               }
               freeGamePopupGate = Global.flashHotParams[MysteryBoxBalloonDialog.FREE_GAME_POP_UP_VERSION] != null ? int(Global.flashHotParams[MysteryBoxBalloonDialog.FREE_GAME_POP_UP_VERSION]) : 0;
               userFreeGamePopupVersion = int(result.freeGamePopup);
               userPayerPopupGate = Global.flashHotParams[MysteryBoxBalloonDialog.PAYER_POPUP_VERSION] != null ? int(Global.flashHotParams[MysteryBoxBalloonDialog.PAYER_POPUP_VERSION]) : 0;
               userPayerPopupVersion = int(result.mysteryGamePopup);
               userSetPayerPopupEligibile = Boolean(result.setBonusPopup);
               LESetManager.init();
               freeGameLevelLock = Boolean(result.freeGameLevelLock);
               if(Global.player.level == 1)
               {
                  suppressDialogs = this.DIALOG_SUPPRESS_ALL;
               }
               if(reactivating != null && reactivating != "")
               {
                  suppressDialogs = this.DIALOG_SUPPRESS_ALL;
                  if(result.reactivating_tier > 1)
                  {
                     plots = Global.world.getObjectsByClass(Plot);
                     for(plotIdx = 0; plotIdx < plots.length; plotIdx++)
                     {
                        plot = plots[plotIdx] as Plot;
                        if(plot.isWithered() || plot.isGrown())
                        {
                           plot.setFullGrown();
                        }
                     }
                  }
               }
               FeatureOptionsManager.getInstance().loadObject(result.userInfo.featureOptions);
               if(result.managedSales)
               {
                  Global.managedSalesManager.setManagedSales(result.managedSales);
               }
               if(result.managedVIPSales)
               {
                  Global.vipSalesManager.setManagedSales(result.managedVIPSales);
               }
               if(result.worldSpecificSales)
               {
                  Global.worldSpecificSalesManager.setWorldSpecificSale(result.worldSpecificSales);
               }
               if(result.categorySpecificSales)
               {
                  Global.categorySpecificSalesManager.setCategorySpecificSale(result.categorySpecificSales);
               }
               if(result.genericCharity)
               {
                  Global.charityManager.setCharity(result.genericCharity);
               }
               Global.crosspromoDescriptorManager.setCrossPromoData(result.crossPromos);
               if(result.crossPromos != null && result.crossPromos.length > 0)
               {
                  FarmStatsManager.sample(100,"zcrosspromo","tinituser","crosspomos_count",result.crossPromos.length);
               }
               else
               {
                  FarmStatsManager.sample(100,"zcrosspromo","tinituser","crosspomos_count","no_promos");
               }
               Global.ui.initActionMenu();
               Global.postInitActionsManager.dialogSupress = suppressDialogs > this.DIALOG_SUPPRESS_NONE;
               if(result.userInfo.currentWorldType)
               {
                  Global.worldManager.setCurrentWorldType(result.userInfo.currentWorldType);
               }
               Global.player.energy = result.energy;
               if(result.hasOwnProperty("fbEventRsvpStatus"))
               {
                  rsvpResult = result.fbEventRsvpStatus;
                  rsvpStatus = new Object();
                  for(rsvpKey in rsvpResult)
                  {
                     newKey = rsvpKey.split("_").join("");
                     rsvpStatus[newKey] = rsvpResult[rsvpKey];
                  }
                  Global.player.fbEventStatusList = rsvpStatus;
               }
               if(result.hasOwnProperty("smartSystemCraftShopConfig"))
               {
                  Global.player.smartSystemCraftShopConfig = result.smartSystemCraftShopConfig;
               }
               if(result.hasOwnProperty("smartSystemCraftingCottageConfig"))
               {
                  Global.player.smartSystemCraftingCottageConfig = result.smartSystemCraftingCottageConfig;
               }
               if(result.hasOwnProperty("smartSystemFarmStandConfig"))
               {
                  Global.player.smartSystemFarmStandConfig = result.smartSystemFarmStandConfig;
               }
               if(result.hasOwnProperty("subscriptionsUrl"))
               {
                  Global.subscriptionsUrl = result.subscriptionsUrl;
               }
               Global.hud.showMessageCenterButton();
               if(result.licenses)
               {
                  for(licensedItemCode in result.licenses)
                  {
                     LicenseManager.getInstance().addLicense(licensedItemCode,result.licenses[licensedItemCode]);
                  }
               }
               if(result.packPurchases)
               {
                  for(packId in result.packPurchases)
                  {
                     PackPurchaseManager.getInstance().addPackPurchase(packId,result.packPurchases[packId]);
                  }
               }
               Global.witherOnObject = result.witherOn;
               if(Global.flashHotParams.hasOwnProperty("DISABLE_FAST_TRAVEL") && Boolean(Global.flashHotParams["DISABLE_FAST_TRAVEL"]))
               {
                  for(key in Global.witherOnObject)
                  {
                     if(Global.witherOnObject[key] == false)
                     {
                        Global.player.setSeenFlag("cachedWorldLoadDisabled",true,true);
                        break;
                     }
                  }
               }
               if(Global.farmSocialNetwork.oneToOneFeedsSupported())
               {
                  Global.featureBuyableGifts = result.featureBuyableGifts;
               }
               if(result.promoReloadIndexes != null)
               {
                  Global.player.nextMarketPromos = result.promoReloadIndexes;
               }
               Global.player.isFarmvilleFan = result.isFarmvilleFan;
               Global.player.setFanPageStatuses(result.fanPageStatuses);
               Global.player.subscriptionStatus = result.subscriptionStatus;
               if(Boolean(result.userInfo.player.hideAvatar) && "1" == result.userInfo.player.hideAvatar)
               {
                  Global.player.setAvatarVisible(false);
               }
               if(Boolean(result.userInfo.player.hideAvatarArrowIndicator) && "1" == result.userInfo.player.hideAvatarArrowIndicator)
               {
                  Global.player.setAvatarArrowIndicatorVisible(false);
               }
               if(Boolean(result && result.seasonData && result.seasonData["nextSeasonAvailable"]) && Boolean(Global.worldManager) && Boolean(Global.worldManager.currentWorldType))
               {
               }
               if(result.breedingSkillStates)
               {
                  for(featureName in result.breedingSkillStates)
                  {
                     if(featureName == "dragon_pen_finished")
                     {
                        Global.player.getDragonBreedingSkillStateForFeature(featureName).initializeFromInitUser(result.breedingSkillStates[featureName]);
                     }
                     else
                     {
                        Global.player.getBreedingSkillStateForFeature(featureName).initializeFromInitUser(result.breedingSkillStates[featureName]);
                     }
                  }
               }
               if(result.showPackToaster)
               {
                  suppressDialogs = this.DIALOG_SUPPRESS_ALL;
                  Global.postInitActionsManager.addInitAction(new PostInitToaster(new PackPurchasedToaster()));
               }
               if(result.showPromoToaster)
               {
                  Global.postInitActionsManager.addInitAction(new PostInitToaster(new IconToasterWindow(ToasterIconPaths.CASH_MINI_ICON,ZLocUtils.t("Dialogs","BuyerPromo_ToasterMessage"))));
               }
               if(result["ingamePaymentPackages"])
               {
                  InGamePaymentsManager.packages = result["ingamePaymentPackages"];
               }
               if(result["ugcItemData"])
               {
                  Global.player.loadUGCItemData(result.ugcItemData);
               }
               if(result["sentGiftsList"])
               {
                  Global.player.sentGifts = result.sentGiftsList;
               }
               if(result["leaderboards"])
               {
                  Global.player.initLeaderboardStates(result["leaderboards"]);
               }
               if(result["seedHarvestCountsSinceLastBushelDrop"])
               {
                  Global.player.setAllSeedHarvestCountsSinceLastBushelDrop(result["seedHarvestCountsSinceLastBushelDrop"]);
               }
               userInfo = result.userInfo;
               if(userInfo.player)
               {
                  Global.player.loadObject(userInfo.player);
                  Global.player.newPlayer = userInfo.is_new;
                  Global.player.firstDay = userInfo.firstDay;
                  Global.player.firstDayTimestamp = userInfo.firstDayTimestamp;
               }
               if(ChatManager.instance.isFarmTalkEnabled() && Global.player.farmTalkPermission)
               {
                  ZoomManager.initConnection();
               }
               shouldLoadWorld = false;
               if(null == m_worldToLoad)
               {
                  shouldLoadWorld = true;
                  m_worldToLoad = result.world;
               }
               else
               {
                  result.world = m_worldToLoad;
               }
               if(result.limitedSaleEligible == true)
               {
                  LimitedSaleUtility.isEligible = true;
               }
               if(result.hasOwnProperty("instanceDataStore"))
               {
                  InstanceDataStoreManager.loadObject(result.instanceDataStore.store);
               }
               Global.worldManager.onUserInit(result,shouldLoadWorld);
               result = result.userInfo;
               FreezeManager.freezingUnlocked = true;
               VotingDataManager.getInstance().initialize();
               if(result.avatar != null)
               {
                  avatar = new FarmAvatar(result.avatar);
                  Global.world.addPlayerAvatar(avatar);
                  avatar.setSelected(true);
               }
               else
               {
                  Global.postInitActions.add(new DoCreateNewAvatar());
               }
               TutController.createTutorial();
               if(result.attr)
               {
                  Global.player.setNameFromServer(result.attr.name);
                  if(Global.hud.farmNameDisplay)
                  {
                     Global.hud.farmNameDisplay.setFarmNameFromPlayerName(result.attr.name);
                  }
               }
               ExternalInterface.call("onWorldLoad");
               if(result.player.buffs)
               {
                  for(buffX in result.player.buffs)
                  {
                     Global.player.buffs[buffX] = result.player.buffs[buffX];
                  }
                  Global.player.applyAllBuffs();
               }
               if(result.player)
               {
                  Global.player.loadStatsFromPlayerObject(result.player);
               }
               if(result.player.storageData)
               {
                  storageData = result.player.storageData;
                  itemCode = "";
                  for(itemCode in storageData[Global.world.GIFTBOX_ID])
                  {
                     giftData = storageData[Global.world.GIFTBOX_ID][itemCode] as Array;
                     if(giftData)
                     {
                        Global.player.addGiftData(giftData,itemCode);
                     }
                  }
                  if(storageData[Global.world.CONSUME_ID])
                  {
                     for(itemCode in storageData[Global.world.CONSUME_ID])
                     {
                        Global.player.addGiftData(storageData[Global.world.CONSUME_ID][itemCode],itemCode);
                     }
                  }
               }
               if(result.iconCodes)
               {
                  Global.hud.iconQueue.setIcons(result.iconCodes,true);
                  Global.hud.rightSideIconQueue.setIcons(result.iconCodes,true);
               }
               if(Boolean(result.doobersManager) && Boolean(result.doobersManager[DoobersManager.INIT_SALT_KEY]))
               {
                  DoobersManager.getInstance().setInitSalt(result.doobersManager[DoobersManager.INIT_SALT_KEY]);
               }
               if(Boolean(result.collectionsManager) && Boolean(result.collectionsManager[CollectionsManager.INIT_SALT_KEY]))
               {
                  CollectionsManager.getInstance().setInitSalt(result.collectionsManager[CollectionsManager.INIT_SALT_KEY]);
               }
               if(!result.is_new)
               {
                  if(suppressDialogs == this.DIALOG_SUPPRESS_NONE && !Global.player.isNewPlayer)
                  {
                     if(result.dailyLotteryAmount > 0 && Global.player.gold < Global.farmGameSettingsManager.getInt("raffleThreshold",10000))
                     {
                        Global.postInitActionsManager.addInitAction(new PostInitPopup(new DailyLottery(result.dailyLotteryAmount)));
                     }
                  }
                  if(suppressDialogs == this.DIALOG_SUPPRESS_NONE)
                  {
                     if(Boolean(friendUnwithered) && friendUnwithered > 0)
                     {
                        messageTitle = ZLocUtils.t("Dialogs","UnwitherFriendDidIt_Title");
                        messageText = ZLocUtils.t("Dialogs","UnwitherFriendDidIt");
                        Global.postInitActionsManager.addInitAction(new PostInitToaster(new TwoIconTitleToasterWindow(messageTitle,messageText,Global.getFBPicUrl(friendUnwithered),ToasterIconPaths.UNWITHER_ICON,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),null,null)));
                     }
                  }
                  if(Global.player.getSeenFlag(this.PROMO_MOTD_SEEN_FLAG) != true || Global.player.level < 5)
                  {
                     if(Global.player.getSeenFlag("cross_gifting_received_75") == true)
                     {
                        this.showCrossGameOnboarding();
                     }
                  }
                  Global.player.setSeenFlag(this.PROMO_MOTD_SEEN_FLAG);
                  if(Global.player.incrementalGateArray)
                  {
                     for each(incrementalGateItem in Global.player.incrementalGateArray)
                     {
                        acquired = incrementalGateItem.acquired;
                        for(code in acquired)
                        {
                           gateItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
                           if(Boolean(gateItem) && gateItem.limit > 0)
                           {
                              for(count = int(acquired[code]); count > 0; )
                              {
                                 Global.player.addLimitedItem(gateItem.name);
                                 count--;
                              }
                           }
                        }
                     }
                  }
                  if(suppressDialogs == this.DIALOG_SUPPRESS_NONE)
                  {
                     EmailManager.parseEmailBits(result);
                  }
                  if(Global.world.getObjectsByClass(Tractor).length > 0)
                  {
                     if(!Global.player.getSeenFlag(Tractor.FIRST_TRACTOR_PLACEMENT_FLAG))
                     {
                        Global.player.setSeenFlag(Tractor.FIRST_TRACTOR_PLACEMENT_FLAG);
                     }
                  }
               }
               if(npcNeighbors)
               {
                  for each(npcData in npcNeighbors)
                  {
                     NPCManager.getInstance().addNPC(new NPCConfigData(npcData));
                  }
               }
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LAZYLOAD_NEIGHBORBAR) == 1)
               {
                  Global.friendManager.setCompressedString(neighbors);
               }
               else
               {
                  Global.friendManager.setUnparsedFriendData(neighbors);
               }
               for each(worldId in WorldsConstants.ALL_WORLDS)
               {
                  expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
                  if(expansionData != null)
                  {
                     forallAccess = expansionData.getAccessOfType(ExpansionAccess.TYPE_ALL);
                     if(forallAccess != null)
                     {
                        Global.postInitActionsManager.addInitAction(new UnlockExpansionWorldAction(worldId,ExpansionAccess.TYPE_ALL));
                     }
                  }
               }
               if(m_worldToLoad)
               {
                  MessageManager.getInstance().loadObject(m_worldToLoad.messageManager);
               }
               SocialActionsManager.getInstance().loadObject(socialActions);
               ItemBuffManager.getInstance().loadObject(result.itemBuffManager);
               Global.player.setInitUserDone();
               Global.player.updateNameFromSNUser();
               if(userLocale != "")
               {
                  Global.player.snUser.locale = userLocale;
               }
               this.autoConsumeGiftBoxItems();
               m_worldToLoad = null;
               ChatManager.init();
            }
            else
            {
               ErrorManager.addError("InitUser global state is invalid",ErrorManager.ERROR_REMOTEOBJECT_FAULT);
            }
         }
         else
         {
            ErrorManager.addError("InitUser result is null",ErrorManager.ERROR_REMOTEOBJECT_FAULT);
         }
         Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_CHANGED));
         if(StageQuality.HIGH.toUpperCase() == Global.stage.quality)
         {
            Global.stage.quality = StageQuality.MEDIUM;
         }
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_EXTENDED_PERMISSIONS);
         if(variant == Experiments.USE_EXTENDENDED_PUBLISH_PERMISSION_VARIANT && GlobalEngine.socialNetwork is FacebookSocialNetwork)
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).checkForPublishPermission(Global.player.uid,this.recordExtendedPermissionsStats);
         }
         StatsManager.sendStats();
         this.startPostInit();
         SystemNotificationManager.getInstance().resetNotifications();
         TReceiveAllPresents.ReceiveAll(false);
         if(ChatManager.instance.isFarmTalkEnabled() && Global.player.farmTalkPermission)
         {
            ZoomManager.readyForData();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MATCHMAKING_ENABLE) > 0)
         {
            Security.loadPolicyFile("xmlsocket://zoom.zynga.com:843");
         }
         GrowableInstanceDataProxy.resetInstances();
         InstanceDataStoreManager.onUserChange(null);
         if(Global.suppressAllInitUserDialogs)
         {
            UI.stopPopups(false);
         }
         FarmLoadPhaseMonitor.updateLoadPhase(FarmLoadPhaseMonitor.USERINIT);
      }
      
      private function startPostInit() : void
      {
         TransactionManager.addTransaction(new TPostInit(),true);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function recordExtendedPermissionsStats(hasPublishPermission:Boolean, hasEmailPermission:Boolean) : void
      {
         if(hasPublishPermission == false)
         {
            Global.player.hasPublishPermission = hasPublishPermission;
         }
         if(hasPublishPermission)
         {
            FarmStatsManager.count("extended_permissions","granted","yes");
         }
         else
         {
            FarmStatsManager.count("extended_permissions","granted","no");
         }
      }
      
      protected function onWelcomeGiftPopupClosed(event:GenericPopupEvent) : void
      {
         TransactionManager.addTransaction(new TReceiveWelcomeGift());
      }
      
      protected function showWishlistGrantedDialog() : void
      {
         var dialog:WishlistNotifyPopup = new WishlistNotifyPopup(this.m_wishSenders,this.m_wishImage,this.m_wishRewardLink,this.m_wishName);
         Global.postInitActionsManager.addInitAction(new PostInitPopup(dialog));
      }
      
      protected function onBuyUnwither(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMiniMarketDialog(["unwither_3"]);
         }
      }
      
      protected function onCloseFuelOfferDialog(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            UI.displayMarketDialog("fuelPriceDialog","vehicle");
            FarmStatsManager.count("fv_fuel_price_test","fuel_dialog_click_accept");
         }
         else
         {
            FarmStatsManager.count("fv_fuel_price_test","fuel_dialog_click_cancel");
         }
      }
      
      protected function onBookmarkReward(event:GenericPopupEvent) : void
      {
         Global.player.gold += this.m_bookmarkCash;
      }
      
      private function getTimezoneOffset() : Number
      {
         var now:Date = new Date();
         return now.timezoneOffset;
      }
      
      private function enterGameMessageAndSetHudIcon(suppressDialog:Boolean, itemName:String, promoXML:XML) : void
      {
         var iconUrl:String = null;
         var promoMessage:String = null;
         var promoDialog:GenericIconPopup = null;
         var enterGameMsgFlag:String = this.getLimitedEditionPromoSeenFlagName(this.PROMO_TYPE_ENTER_GAME_MSG,itemName);
         if(Boolean(!Global.player.getSeenFlag(enterGameMsgFlag) && promoXML.@enterGameMessage) && Boolean(this.shouldShowLimitedEditionPromo(promoXML.@enterGameMessage)) && !suppressDialog)
         {
            Global.player.setSeenFlag(enterGameMsgFlag);
            iconUrl = Global.farmGameSettingsManager.getImageByName(itemName,"icon");
            promoMessage = ZLocUtils.t("Dialogs","LimitedEditionPromo_" + itemName + "_message");
            promoDialog = new GenericIconPopup(promoMessage,GenericPopup.TYPE_OK,this.onLimitedEditionPromoClose,iconUrl);
            Global.postInitActionsManager.addInitAction(new PostInitPopup(promoDialog));
         }
         var hudIconFlag:String = this.getLimitedEditionPromoSeenFlagName(this.PROMO_TYPE_HUD_ICON,itemName);
         if(Boolean(!Global.player.getSeenFlag(hudIconFlag)) && Boolean(promoXML.@hudIcon) && this.shouldShowLimitedEditionPromo(promoXML.@hudIcon))
         {
            Global.player.setSeenFlag(hudIconFlag);
            Global.hud.iconQueue.addIcon("LimitedEditionPromo_" + itemName);
         }
      }
      
      private function onLimitedEditionPromoClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
         }
      }
      
      private function shouldShowLimitedEditionPromo(promoVisibility:String) : Boolean
      {
         var shouldShow:Boolean = false;
         switch(promoVisibility)
         {
            case this.PROMO_VISIBILITY_FANS:
               if(Global.player.isFarmvilleFan)
               {
                  shouldShow = true;
               }
               break;
            case this.PROMO_VISIBILITY_ALL:
               shouldShow = true;
               break;
            default:
               shouldShow = false;
         }
         return shouldShow;
      }
      
      private function getLimitedEditionPromoSeenFlagName(promoType:String, itemName:String) : String
      {
         return promoType + "_" + itemName;
      }
      
      private function showCrossGameOnboarding() : void
      {
         var dialog:FarmDynamicDialog = null;
         var message:String = null;
         if(Global.player.getSeenFlag("cross_gifting_onboarding_75") == false)
         {
            dialog = FarmDynamicDialog.createDialog("XPromoOnboardingDialog",FarmDynamicDialog);
            dialog.setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,"Congratulations");
            message = ZLocUtils.t_pk("Dialogs:OnboardingBodyText",null,{"item":ZLocUtils.tk_pk("brick_friendlyName")});
            dialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,message);
            dialog.setShortcutAttribute("okayButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Okay"));
            dialog.setShortcutListener("okayButton",WidgetControllerEvent.BUTTON_PRESSED,this.onOkayPress);
            dialog.setup();
            dialog.show();
            Global.player.setSeenFlag("cross_gifting_onboarding_75");
         }
      }
      
      private function autoConsumeGiftBoxItems() : void
      {
         var xmlItem:XML = null;
         var itemName:String = null;
         var item:FarmItem = null;
         var itemCount:uint = 0;
         var i:int = 0;
         var autoConsumeItems:XMLList = Global.farmGameSettingsManager.getAutoConsumeGiftBoxItems();
         for each(xmlItem in autoConsumeItems)
         {
            itemName = xmlItem.@name;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item != null)
            {
               itemCount = uint(Global.player.getGiftCountForItemKey(item.code));
               if(itemCount > 0 && (item.type == FarmItemType.CONSUMABLE || item.subType == FarmItemType.CONSUMABLE || item.isConsumable))
               {
                  for(i = 0; i < itemCount; i++)
                  {
                     item.onUse(0,{
                        "isGift":false,
                        "allowReshopping":false
                     });
                     Global.player.removeGift(null,itemName);
                  }
               }
            }
         }
      }
      
      public function onOkayPress(event:WidgetControllerEvent) : void
      {
         var itemName:String = Global.farmGameSettingsManager.getInGameItemByGameID(CrossPromoConstants.CITY_GAME_ID);
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var giftItemLimit:int = parseInt(giftItem["limit"]);
         var giftItemsInWorld:Array = Global.world.getObjectsByNames([itemName]);
         var giftItemsInBox:int = Global.player.getGiftCountForItem(itemName);
         if(giftItemLimit > 0 && giftItemsInWorld.length + giftItemsInBox < giftItemLimit)
         {
            TransactionManager.addTransaction(new TIntegratedCrossGameOnboarding(itemName,CrossPromoConstants.CITY_GAME_ID),true);
         }
      }
   }
}

