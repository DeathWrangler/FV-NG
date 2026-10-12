package Managers.InGameConsole
{
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.FarmTileMap;
   import Display.MOTD;
   import Engine.Classes.World;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGetMOTD;
   import Widgets.Constants.Market.Currency;
   import flash.utils.Dictionary;
   
   public final class ConsoleStandardCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      private const STATIC_IDENTIFIER:String = "static";
      
      private const DYNAMIC_IDENTIFIER:String = "dynamic";
      
      private const MAX_GOLD_SET_AMOUNT:Number = 999999999;
      
      private const MAX_CASH_SET_AMOUNT:Number = 99999;
      
      private const MAX_LOYALTY_SET_AMOUNT:Number = 99999;
      
      private const MAX_XP_SET_AMOUNT:int = 2147483647;
      
      public function ConsoleStandardCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "std";
      }
      
      public function setGold(amount:String) : String
      {
         var returnString:String = "";
         var amountNumber:Number = parseInt(amount,10);
         var amountString:String = amountNumber.toString();
         if(amountString != amount)
         {
            returnString = "Gold not set: \'amount\' either not a valid number or is above the maximum (" + Math.min(this.MAX_GOLD_SET_AMOUNT,Number.MAX_VALUE).toString() + ")";
         }
         else
         {
            amountNumber = Math.min(Math.abs(amountNumber),this.MAX_GOLD_SET_AMOUNT);
            Global.player.gold = amountNumber;
            sendTransaction("adminCall",{
               "adminController":"CPanelUserStatsController",
               "adminCommand":"setPlayerAttributes",
               "gold":Global.player.gold.toString()
            });
            returnString = "Player now has " + amountNumber.toString() + " gold.";
         }
         return returnString;
      }
      
      public function setLoyaltyPoints(amount:String) : String
      {
         var returnString:String = "";
         var amountNumber:Number = parseInt(amount,10);
         var amountString:String = amountNumber.toString();
         if(amountString != amount)
         {
            returnString = "loyalty points not set: \'amount\' either not a valid number or is above the maximum (" + Math.min(this.MAX_LOYALTY_SET_AMOUNT,Number.MAX_VALUE).toString() + ")";
         }
         else
         {
            amountNumber = Math.min(Math.abs(amountNumber),this.MAX_LOYALTY_SET_AMOUNT);
            Global.player.updateWorldCurrency(Currency.COST_STATUS_POINTS,amountNumber);
            sendTransaction("setLoyaltyPoints",{"amount":amountNumber});
            returnString = "Player now has more Loyalty Points.";
         }
         return returnString;
      }
      
      public function setCash(amount:String) : String
      {
         var returnString:String = "";
         var amountNumber:Number = parseInt(amount,10);
         var amountString:String = amountNumber.toString();
         if(amountString != amount)
         {
            returnString = "Cash not set: \'amount\' either not a valid number or is above the maximum (" + Math.min(this.MAX_CASH_SET_AMOUNT,Number.MAX_VALUE).toString() + ")";
         }
         else
         {
            amountNumber = Math.min(Math.abs(amountNumber),this.MAX_CASH_SET_AMOUNT);
            Global.player.cash = amountNumber;
            sendTransaction("adminCall",{
               "adminController":"CPanelUserStatsController",
               "adminCommand":"setPlayerAttributes",
               "cash":Global.player.cash.toString()
            });
            returnString = "Player now has " + amountNumber.toString() + " FV cash.";
         }
         return returnString;
      }
      
      public function setActionCount(key:String, count:int) : String
      {
         Global.player.setActionCount(key,count,true);
         return "Action count " + key + " now has value " + count.toString();
      }
      
      public function resetDebugDate() : String
      {
         var date:Date = null;
         date = new Date();
         sendTransaction("resetDebugTimeInGame",{},function(result:Object):void
         {
            Global.worldManager.syncWorldTime(date.getTime() / 1000 - 10800);
            GlobalEngine.setInternalServerTime(date.getTime() / 1000 - 10800);
         });
         Global.mapUrls = {};
         return "Reset the date of the game to " + date.toString();
      }
      
      public function setDebugDate(month:int, day:int, year:int, hour:int = 0, minute:int = 0, second:int = 0, isStatic:Boolean = false) : String
      {
         var date:Date = null;
         date = new Date(year,month - 1,day,hour,minute,second);
         var debugValue:String = month.toString() + "/" + day.toString() + "/" + year.toString() + " " + hour.toString() + ":" + minute.toString() + ":" + second.toString();
         var type:String = isStatic ? this.STATIC_IDENTIFIER : this.DYNAMIC_IDENTIFIER;
         sendTransaction("setDebugTimeInGame",{
            "debugTime":debugValue,
            "type":type
         },function(result:Object):void
         {
            Global.worldManager.syncWorldTime(date.getTime() / 1000 - 10800);
            GlobalEngine.setInternalServerTime(date.getTime() / 1000 - 10800);
            if(result.blacklistData)
            {
               Global.mapUrls = result.blacklistData;
            }
         });
         return "Setting the date of the game to " + date.toString() + "... Running: " + type + "ally";
      }
      
      public function advanceTime(metric:String, advanceTime:int) : String
      {
         var date:Date = null;
         var result:String = "Advancing the game " + advanceTime + " " + metric;
         switch(metric)
         {
            case "seconds":
               break;
            case "minutes":
               advanceTime *= FarmGameUtil.NUM_SECS_IN_MINUTE;
               break;
            case "hours":
               advanceTime *= FarmGameUtil.NUM_SECS_IN_HOUR;
               break;
            case "days":
               advanceTime *= FarmGameUtil.NUM_SECS_IN_DAY;
               break;
            case "weeks":
               advanceTime *= FarmGameUtil.NUM_SECS_IN_DAY * FarmGameUtil.NUM_DAYS_IN_WEEK;
               break;
            default:
               result = "Invalid metric \'" + metric + "\'. Please choose either \'seconds\', \'minutes\', \'hours\', \'days\', or \'weeks\'";
         }
         date = new Date(GlobalEngine.serverTime + advanceTime * FarmGameUtil.NUM_MSECS_IN_SECOND);
         sendTransaction("advanceTime",{"advanceTime":advanceTime},function(result:Object):void
         {
            Global.worldManager.syncWorldTime(date.getTime() / FarmGameUtil.NUM_MSECS_IN_SECOND);
            GlobalEngine.setInternalServerTime(date.getTime() / FarmGameUtil.NUM_MSECS_IN_SECOND);
            if(result.blacklistData)
            {
               Global.mapUrls = result.blacklistData;
            }
         });
         return result;
      }
      
      public function resetMastery() : String
      {
         Global.player.mastery = new Object();
         Global.player.masteryCounters = new Object();
         sendTransaction("adminCall",{
            "adminController":"CPanelGrowPlotsController",
            "adminCommand":"resetMastery"
         });
         return "All mastery values reset";
      }
      
      public function setMastery(itemName:String, masteryPoints:int) : String
      {
         var output:String = "Invalid mastery name";
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(Boolean(farmItem) && Boolean(farmItem is HarvestableItem) && (farmItem as HarvestableItem).hasMastery)
         {
            Global.player.masteryCounters[farmItem.code] = masteryPoints;
            sendTransaction("adminCall",{
               "adminController":"CPanelMasteryController",
               "adminCommand":"setItemMastery",
               "masteryCount":masteryPoints.toString(),
               "itemCode":Global.farmGameSettingsManager.getFarmItemCodeByName(itemName)
            });
            output = "Item: " + itemName + "\nMastery Counter: " + masteryPoints.toString();
         }
         return output;
      }
      
      public function rigMastery(masteryType:String, level:int) : String
      {
         var masteryObj:Object = null;
         var allMasteryObjs:Array = Global.farmGameSettingsManager.getFarmItemsArrayByType(masteryType);
         for each(masteryObj in allMasteryObjs)
         {
            this.rigMasteryObject(masteryObj,level);
         }
         sendTransaction("adminCall",{
            "adminController":"CPanelMasteryController",
            "adminCommand":"rigMasteryForType",
            "level":level,
            "masteryTpe":masteryType
         });
         return "All " + masteryType + " mastery rigged to level " + level;
      }
      
      public function rigMasteryObject(masteryObj:Object, diffculty:int) : void
      {
         var levelDetails:Object = null;
         var count:int = 0;
         if(masteryObj.hasOwnProperty("mastery") && masteryObj["mastery"] == true)
         {
            if(masteryObj.hasOwnProperty("levels") && Boolean(masteryObj["levels"].hasOwnProperty(diffculty)))
            {
               levelDetails = masteryObj["levels"][diffculty];
               count = levelDetails["count"] - 1;
               Global.player.masteryCounters[masteryObj["code"]] = count;
               if(diffculty == 0)
               {
                  Global.player.mastery = {};
               }
               else
               {
                  Global.player.mastery[masteryObj["code"]] = diffculty - 1;
               }
            }
         }
      }
      
      public function setXp(amount:String) : String
      {
         var returnString:String = "";
         var amountNumber:int = parseInt(amount,10);
         var amountString:String = amountNumber.toString();
         if(amountString != amount)
         {
            returnString = "XP not set: \'amount\' either not a valid number or is above the maximum (" + Math.min(this.MAX_XP_SET_AMOUNT,int.MAX_VALUE).toString() + ")";
         }
         else
         {
            amountNumber = Math.min(Math.abs(amountNumber),this.MAX_XP_SET_AMOUNT);
            Global.player.calculateAndAddXp(amountNumber - Global.player.xp,false);
            Global.player.level = Global.farmGameSettingsManager.getLevelForXP(amountNumber);
            sendTransaction("adminCall",{
               "adminController":"CPanelUserStatsController",
               "adminCommand":"setPlayerAttributes",
               "xp":amountString
            });
            returnString = "New XP: " + amountNumber.toString() + "\nNew Level: " + Global.player.level;
         }
         return returnString;
      }
      
      public function changeExperiment(experimentName:String, variant:int) : String
      {
         var output:String = "Experiment \'" + experimentName + "\' set to variant " + variant.toString();
         Global.experimentManager.setVariant(experimentName,variant);
         sendTransaction("adminCall",{
            "adminController":"CPanelExperimentsController",
            "adminCommand":"addNewExperiment",
            "experimentName":experimentName,
            "experimentVariant":variant.toString()
         });
         return output;
      }
      
      public function triggerMOTD(motdName:String) : String
      {
         var output:String = "MOTD \'" + motdName + "\'is being called to the server to be triggered.";
         sendTransaction("adminCall",{
            "adminController":"CPanelMotdController",
            "adminCommand":"setCurrentMOTD",
            "motdName":motdName
         });
         TransactionManager.addTransaction(new TGetMOTD(motdName,this.onCompleteTriggerMOTD),true);
         return output;
      }
      
      public function removeMOTDSeenFlag(motdName:String) : String
      {
         var output:String = "MOTD \'" + motdName + "\' seen flag is being removed";
         sendTransaction("adminCall",{
            "adminController":"CPanelMotdController",
            "adminCommand":"removeMOTDSeenFlag",
            "motdName":motdName
         });
         return output;
      }
      
      public function forceFOTD(fotdURL:String) : String
      {
         var output:String = "Loading screen with url \'" + fotdURL + "\' will be shown on next load.";
         sendTransaction("adminCall",{
            "adminController":"CPanelMotdController",
            "adminCommand":"forceFOTD",
            "fotdURL":fotdURL
         });
         return output;
      }
      
      public function checkFlashParam(paramName:String) : String
      {
         var output:String = "Flash Param " + paramName + " Status:    ";
         if(Global.flashHotParams.hasOwnProperty(paramName))
         {
            output += Global.flashHotParams[paramName];
         }
         else
         {
            output += "FLASHPARAM DOES NOT EXIST";
         }
         return output;
      }
      
      public function addItemToGiftbox(nameList:String, quantity:int = 1) : String
      {
         var name:String = null;
         var item:FarmItem = null;
         var output:String = "";
         var names:Array = nameList.replace(/\s/g,"").split(/,/g);
         var validNames:Array = [];
         for each(name in names)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(name);
            if(item != null)
            {
               validNames.push(name);
               Global.player.addGift(name,"0",quantity);
               output += "Successfully adding " + quantity.toString() + " of the item \'" + name + "\' to your giftbox\n";
            }
            else
            {
               output += "No item exists with the name: " + name;
            }
         }
         if(validNames.length > 0)
         {
            sendTransaction("adminCall",{
               "adminController":"CPanelGiftingController",
               "adminCommand":"addNewGift",
               "giftName":validNames.join(","),
               "giftAmount":quantity.toString()
            });
         }
         return output;
      }
      
      public function clearGiftbox() : String
      {
         Global.player.gifts = new Dictionary();
         sendTransaction("adminCall",{
            "adminController":"CPanelGiftingController",
            "adminCommand":"resetAllGifts"
         });
         return "Giftbox cleared!";
      }
      
      public function resetCaps() : String
      {
         Global.player.resetActionCounts();
         Global.player.resetFeaturesLastShown();
         Global.player.sentGifts = {};
         sendTransaction("adminCall",{
            "adminController":"CPanelSeenFlagsController",
            "adminCommand":"deleteCaps"
         });
         return "Caps have been deleted.";
      }
      
      public function resetSeenFlags() : String
      {
         var output:String = "Reset All Seen Flags";
         Global.player.resetSeenFlags();
         sendTransaction("adminCall",{
            "adminController":"CPanelSeenFlagsController",
            "adminCommand":"resetSeenFlags"
         });
         return output;
      }
      
      public function setSeenFlag(seenFlag:String, triggered:Boolean = true) : String
      {
         var output:String = "Setting Specific Seen Flag...";
         Global.player.setSeenFlagAdmin(seenFlag,triggered);
         sendTransaction("adminCall",{
            "adminController":"CPanelSeenFlagsController",
            "adminCommand":"setSeenFlag",
            "seenFlag":seenFlag,
            "triggered":triggered
         });
         return output;
      }
      
      public function addCashPurchase(purchaseDate:String) : String
      {
         var output:String = "Purchase for 100 cash on date: " + purchaseDate + " logging to the server";
         sendTransaction("adminCall",{
            "adminController":"CPanelPurchaseEditingController",
            "adminCommand":"addCashPurchase",
            "purchaseDate":purchaseDate
         });
         return output;
      }
      
      public function resetAchievements() : String
      {
         return "UNIMPLEMENTED - P3";
      }
      
      public function resetQuests() : String
      {
         return "UNIMPLEMENTED - P3";
      }
      
      public function expandfarm(size:int) : String
      {
         var output:String = "Your Farm is now expanded to \'" + size + " \'. Please refresh app to see the expanded farm! ";
         sendTransaction("adminCall",{
            "adminController":"CPanelExpansionWorldsController",
            "adminCommand":"expandFarmToAGivenSize",
            "farmSize":size
         },this.onCompleteExpandFarm);
         return output;
      }
      
      public function onCompleteExpandFarm(result:Object) : void
      {
      }
      
      public function onCompleteTriggerMOTD(result:Object) : void
      {
         if(result != null)
         {
            MOTD.displayMOTD(result);
         }
      }
      
      public function unlockWorld(worldName:String) : String
      {
         var rewards:Vector.<Object> = null;
         var output:String = "\'" + worldName + "\' is not a valid world, check gameSettings.xml for all world definitions";
         if(Global.farmGameSettingsManager.getExpansionData(worldName) != null)
         {
            output = "Unlocking " + worldName + ", check the travel drop down menu";
            sendTransaction("adminCall",{
               "adminController":"CPanelExpansionWorldsController",
               "adminCommand":"unlockWorld",
               "worldType":worldName
            });
            rewards = new Vector.<Object>();
            rewards.push({
               "type":QuestConstants.REWARD_UNLOCK_WORLD,
               "value":worldName
            });
            UserRewardUtil.grantUserRewards(rewards);
         }
         return output;
      }
      
      public function resetExpansionWorld(worldName:String) : String
      {
         var output:String = "\'" + worldName + "\' is not a valid world, check gameSettings.xml for all world definitions";
         if(Global.farmGameSettingsManager.getExpansionData(worldName) != null)
         {
            output = "Resetting " + worldName + ", refresh your app in a few seconds.";
            sendTransaction("adminCall",{
               "adminController":"CPanelExpansionWorldsController",
               "adminCommand":"resetWorld",
               "worldType":worldName
            });
         }
         return output;
      }
      
      public function setWorldCurrency(currencyName:String, amount:int) : String
      {
         var params:Object = null;
         var rewards:Vector.<Object> = null;
         var output:String = "\'" + currencyName + "\' is not a valid currency type";
         if(Global.farmGameSettingsManager.getCurrencyData(currencyName) != null)
         {
            output = "Setting " + currencyName + " balance to " + amount.toString();
            params = {
               "adminController":"CPanelExpansionWorldsController",
               "adminCommand":"setWorldCurrency"
            };
            params[currencyName] = amount;
            sendTransaction("adminCall",params);
            rewards = new Vector.<Object>();
            rewards.push({
               "type":QuestConstants.REWARD_UNLOCK_WORLD_CURRENCY,
               "value":amount,
               "unit":currencyName
            });
            UserRewardUtil.grantUserRewards(rewards);
         }
         return output;
      }
      
      public function setWorldScore(scoreUnit:String, amount:int) : String
      {
         var output:String = "\'" + scoreUnit + "\' is not a valid world score type";
         var worldScores:Object = Global.player.worldScores;
         output = "Setting " + scoreUnit + " balance to " + amount.toString();
         var params:Object = {
            "adminController":"CPanelExpansionWorldsController",
            "adminCommand":"setWorldScore"
         };
         params[scoreUnit] = amount;
         sendTransaction("adminCall",params);
         Global.player.adminResetWorldScore(scoreUnit);
         Global.player.addWorldScore(scoreUnit,amount);
         return output;
      }
      
      public function setWorldColors(skyColor:String, bgColor:String, outlineColor:String, outlineAlpha:Number, expansionOutlineColor:String) : String
      {
         var output:String = "Set World Colors: skyColor=" + skyColor + " bgColor=" + bgColor + " outlineColor=" + outlineColor + " outlineAlpha=" + outlineAlpha + " expansionOutlineColor=" + expansionOutlineColor;
         var world:World = World.getInstance();
         var tileMap:FarmTileMap = world.getTileMap() as FarmTileMap;
         tileMap.setBackgroundSkyColor(uint(skyColor));
         Config.VIEWPORT_CLEAR_COLOR = uint(bgColor);
         Global.world.lotOutlineColor = uint(outlineColor);
         Global.world.lotOutlineAlpha = outlineAlpha;
         Global.world.expansionOutlineColor = uint(expansionOutlineColor);
         tileMap.getFarmBackgroundRenderer().resetOutsideImage();
         tileMap.getFarmBackgroundRenderer().resetHorizonImage();
         Global.world.createLotBG(true);
         return output;
      }
      
      public function prepForNewWorldUnlock(worldName:String) : String
      {
         var output:String = "\'" + worldName + "\' is not a valid world, check gameSettings.xml for all world definitions";
         if(Global.farmGameSettingsManager.getExpansionData(worldName) != null)
         {
            output = "Preping account for " + worldName + ", refresh your app in a few seconds.";
            sendTransaction("adminCall",{
               "adminController":"CPanelExpansionWorldsController",
               "adminCommand":"prepAccountForWorld",
               "worldType":worldName
            });
         }
         return output;
      }
      
      public function unlockWorldLicense(worldName:String, licenseType:String) : String
      {
         var output:String = "\'" + worldName + "\' is not a valid world, check gameSettings.xml for all world definitions";
         if(Global.farmGameSettingsManager.getExpansionData(worldName) != null)
         {
            output = "Unlocking world \'" + worldName + "\' with license \'" + licenseType + "\', refresh your app in a few seconds.";
            sendTransaction("adminCall",{
               "adminController":"CPanelExpansionWorldsController",
               "adminCommand":"unlockWorldContentLicense",
               "worldType":worldName,
               "licenseType":licenseType
            });
            Global.worldManager.addWorldContentLicense(worldName,licenseType);
         }
         return output;
      }
      
      public function destroyPhotoContest(eventId:String) : String
      {
         var output:String = "Destroying all MC Keys for event: " + eventId;
         if(eventId != null && eventId != "")
         {
            sendTransaction("adminCall",{
               "adminController":"CPanelExpansionWorldsController",
               "adminCommand":"destroyPhotoContest",
               "eventId":eventId
            });
         }
         return output;
      }
      
      public function forceIntoTopPhotos(eventId:String) : String
      {
         var output:String = "Forcing current photo into top photos: " + eventId;
         if(eventId != null && eventId != "")
         {
            sendTransaction("adminCall",{
               "adminController":"CPanelExpansionWorldsController",
               "adminCommand":"forceIntoTopPhotos",
               "eventId":eventId
            });
         }
         return output;
      }
      
      public function help(functionName:String = "") : String
      {
         var output:String = "";
         if(functionName != "")
         {
            output = ZLocUtils.t("FarmGame","InGameConsoleFunction_" + functionName);
            if(output == null || output == "")
            {
               output = "Function doesn\'t exist OR function has no documentation in FarmGame.properties (\'FarmGame:InGameConsoleFunction_" + functionName + "\')";
            }
            output += "\n";
         }
         else
         {
            output = ZLocUtils.t("FarmGame","InGameConsoleFunction_std.help") + "\n";
         }
         return output;
      }
      
      public function clearFeatureOption(featureName:String, optionName:String = null) : String
      {
         FeatureOptionsManager.resetFeatureOption(featureName,optionName);
         sendTransaction("adminCall",{
            "adminController":"CPanelUserStatsController",
            "adminCommand":"resetFeatureOption",
            "featureName":featureName,
            "optionName":optionName
         });
         var output:String = "Feature option data with name \'" + featureName + "\' ";
         if(optionName)
         {
            output += "and option \'" + optionName + "\' ";
         }
         return output + "deleted!";
      }
      
      public function clearSCB() : String
      {
         this.clearFeatureOption("GhoulBallCraftingBasket");
         this.clearFeatureOption("GhoulBallCraftingBasket_0");
         this.clearFeatureOption("GhoulBallCraftingBasket_1");
         this.clearFeatureOption("GhoulBallCraftingBasket_2");
         var output:String = "Feature option data with name \'" + "GhoulBallCraftingBasket" + "\' ";
         return output + "deleted!";
      }
      
      public function setSCBCurrency(amount:int) : void
      {
         return FeatureOptionsManager.getInstance().setFeatureOption("GhoulBallCraftingBasket","currencyItem",amount);
      }
      
      public function resetSCB() : String
      {
         this.removeMOTDSeenFlag("MOTD_CRAFTING_BASKET_GHOUL_BALL");
         this.triggerMOTD("MOTD_CRAFTING_BASKET_GHOUL_BALL");
         return "GhoulBallCraftingBasket MOTD seen flag cleared and MOTD triggered";
      }
      
      public function getSCB() : String
      {
         var output:String = "Ghoul Ball SCB  ";
         var parent:Object = FeatureOptionsManager.getInstance().getFeatureOption("GhoulBallCraftingBasket");
         if(parent)
         {
            output += "\n" + parent.toArray().toString();
         }
         var c1:Object = FeatureOptionsManager.getInstance().getFeatureOption("GhoulBallCraftingBasket_0");
         if(c1)
         {
            output += "\nGhoulBall Easy - " + c1.toArray().toString();
         }
         var c2:Object = FeatureOptionsManager.getInstance().getFeatureOption("GhoulBallCraftingBasket_1");
         if(c2)
         {
            output += "\nGhoulBall Medium - " + c2.toArray().toString();
         }
         var c3:Object = FeatureOptionsManager.getInstance().getFeatureOption("GhoulBallCraftingBasket_2");
         if(c3)
         {
            output += "\nGhoulBall Hard - " + c3.toArray().toString();
         }
         return output;
      }
   }
}

