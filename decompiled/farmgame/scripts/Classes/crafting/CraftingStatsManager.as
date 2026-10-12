package Classes.crafting
{
   import Classes.buffs.BBushel;
   import Managers.Crafting.CraftingConstants;
   import Managers.FarmStatsManager;
   import flash.utils.getDefinitionByName;
   
   public class CraftingStatsManager
   {
      
      protected static const FOUND_FIRST_BUSHEL:String = "CrFoundFirstBushel";
      
      protected static const USED_FIRST_BUSHEL:String = "CrUsedFirstBushel";
      
      protected static const TAKEN_FIRST_BUSHEL:String = "CrTakenFirstBushel";
      
      protected static const PLACE_FIRST_STALL:String = "CrFirstStall";
      
      protected static const PLACE_SECOND_STALL:String = "CrSecondStall";
      
      protected static const PLACE_THIRD_STALL:String = "CrThirdStall";
      
      protected static const PLACE_FOURTH_STALL:String = "CrFourthStall";
      
      protected static const PLACE_FIFTH_STALL:String = "CrFifthStall";
      
      protected static const MY_STALL_FIRST_VIEW:String = "CrMyStallFirstView";
      
      protected static const AVAILABLE_BUSHEL_FIRST_VIEW:String = "CrAvailableBushelFirstView";
      
      protected static const SILO_FIRST_VIEW:String = "CrSiloFirstView";
      
      protected static const VISITING_MARKET_STALL_FIRST_VIEW:String = "CrVisitStallFirstView";
      
      protected static const REWARD_PAGE_FIRST_VIEW:String = "CrRewardPageFirstView";
      
      public function CraftingStatsManager()
      {
         super();
      }
      
      public static function recordFoundBushel() : void
      {
         recordFoundFirstBushel();
      }
      
      private static function recordFoundFirstBushel() : void
      {
         if(!Global.player.getSeenFlag(FOUND_FIRST_BUSHEL))
         {
            Global.player.setSeenFlag(FOUND_FIRST_BUSHEL);
            FarmStatsManager.sample(100,"farmers_market","Bushel","find_first_bushel");
         }
      }
      
      public static function recordBushelUsed(buffType:int) : void
      {
         recordFirstBushelUsed();
         switch(buffType)
         {
            case BBushel.TYPE_CROPEXP:
               FarmStatsManager.sample(100,"farmers_market","Bushel","use_bushel","xp_bonus");
               break;
            case BBushel.TYPE_LICENSE:
               FarmStatsManager.sample(100,"farmers_market","Bushel","use_bushel","license_bonus");
               break;
            case BBushel.TYPE_MASTERY:
               FarmStatsManager.sample(100,"farmers_market","Bushel","use_bushel","mastery_bonus");
         }
      }
      
      private static function recordFirstBushelUsed() : void
      {
         if(!Global.player.getSeenFlag(USED_FIRST_BUSHEL))
         {
            Global.player.setSeenFlag(USED_FIRST_BUSHEL);
            FarmStatsManager.sample(100,"farmers_market","Bushel","use_bushel_first_time");
         }
      }
      
      public static function recordBushelTaken() : void
      {
         recordFirstBushelTaken();
         if(Global.worldManager.isVisiting())
         {
            FarmStatsManager.sample(100,"farmers_market","Bushel","taken_bushel","from_friends_farm");
         }
         else
         {
            FarmStatsManager.sample(100,"farmers_market","Bushel","taken_bushel","from_your_farm");
         }
      }
      
      private static function recordFirstBushelTaken() : void
      {
         if(!Global.player.getSeenFlag(USED_FIRST_BUSHEL))
         {
            Global.player.setSeenFlag(USED_FIRST_BUSHEL);
            FarmStatsManager.sample(100,"farmers_market","Bushel","taken_bushel_first_time");
         }
      }
      
      public static function recordStallPlaced() : void
      {
         var instances:Array = null;
         var instanceCount:int = 0;
         var statString:String = null;
         var seenFlag:String = null;
         var objectClass:Class = getDefinitionByName("Classes.MarketStallBuilding") as Class;
         if(objectClass != null)
         {
            instances = Global.world.getObjectsByClass(objectClass);
            instanceCount = int(instances.length);
            statString = null;
            seenFlag = null;
            switch(instanceCount)
            {
               case 1:
                  statString = "place_first_stall";
                  seenFlag = PLACE_FIRST_STALL;
                  break;
               case 2:
                  statString = "place_second_stall";
                  seenFlag = PLACE_SECOND_STALL;
                  break;
               case 3:
                  statString = "place_third_stall";
                  seenFlag = PLACE_THIRD_STALL;
                  break;
               case 4:
                  statString = "place_fourth_stall";
                  seenFlag = PLACE_FOURTH_STALL;
                  break;
               case 5:
                  statString = "place_fifth_stall";
                  seenFlag = PLACE_FIFTH_STALL;
            }
            if(statString != null && seenFlag != null)
            {
               if(!Global.player.getSeenFlag(seenFlag))
               {
                  Global.player.setSeenFlag(seenFlag);
                  FarmStatsManager.sample(100,"farmers_market","Stall",statString);
               }
            }
         }
      }
      
      public static function recordMarketStallContextMenuClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","context_menu","click_farmers_market");
      }
      
      public static function recordStallSold() : void
      {
         FarmStatsManager.sample(100,"farmers_market","Stall","sell_stall");
      }
      
      public static function recordStallDeleted() : void
      {
         FarmStatsManager.sample(100,"farmers_market","Stall","delete_stall");
      }
      
      public static function recordMyStallPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_stall_page","view_page");
         recordMyStallPageViewFirstTime();
      }
      
      private static function recordMyStallPageViewFirstTime() : void
      {
         if(!Global.player.getSeenFlag(MY_STALL_FIRST_VIEW))
         {
            Global.player.setSeenFlag(MY_STALL_FIRST_VIEW);
            FarmStatsManager.sample(100,"farmers_market","my_stall_page","view_page_first_time");
         }
      }
      
      public static function recordMyStallPageHowDoesWorkClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_stall_page","click_how_does_this_work");
      }
      
      public static function recordMyStallPageCloseStallClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_stall_page","click_close_stall");
      }
      
      public static function recordMyStallPageCloseStallClickConfirm() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_stall_page","click_close_stall_confirm");
      }
      
      public static function recordAvailableBushelPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","available_bushel_page","view_page");
         recordAvailableBushelPageViewFirstTime();
      }
      
      private static function recordAvailableBushelPageViewFirstTime() : void
      {
         if(!Global.player.getSeenFlag(AVAILABLE_BUSHEL_FIRST_VIEW))
         {
            Global.player.setSeenFlag(AVAILABLE_BUSHEL_FIRST_VIEW);
            FarmStatsManager.sample(100,"farmers_market","available_bushel_page","view_page_first_time");
         }
      }
      
      public static function recordAvailableBushelPageHowDoesWorkClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","available_bushel_page","click_how_does_this_work");
      }
      
      public static function recordAvailableBushelPageCropTypeClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","available_bushel_page","click_crop_type");
      }
      
      public static function recordShoppingPageCraftedGoodClick() : void
      {
         FarmStatsManager.count("crafting_cottage","cottage_ui","shopping_page","click_crafted_good");
      }
      
      public static function recordAvailableBushelPageFriendClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","available_bushel_page","click_friend");
      }
      
      public static function recordSiloPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_inventory_page","view_page");
         recordSiloPageViewFirstTime();
      }
      
      private static function recordSiloPageViewFirstTime() : void
      {
         if(!Global.player.getSeenFlag(SILO_FIRST_VIEW))
         {
            Global.player.setSeenFlag(SILO_FIRST_VIEW);
            FarmStatsManager.sample(100,"farmers_market","my_inventory_page","view_page_first_time");
         }
      }
      
      public static function recordSiloPageHowDoesWorkClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_inventory_page","click_how_does_this_work");
      }
      
      public static function recordSiloPageClickUse() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_inventory_page","click_use");
      }
      
      public static function recordSiloPageClickShareViewPage() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_inventory_page","click_share","view_page");
      }
      
      public static function recordSiloPageClickShareConfirm() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_inventory_page","click_share","click_share");
      }
      
      public static function recordFriendMarketStallPageView() : void
      {
         if(Global.worldManager.isVisiting())
         {
            FarmStatsManager.sample(100,"farmers_market","friend_market_stall_page","view_page","from_friends_farm");
         }
         else
         {
            FarmStatsManager.sample(100,"farmers_market","friend_market_stall_page","view_page","from_your_farm");
         }
         recordFriendMarketStallPageViewFirstTime();
      }
      
      private static function recordFriendMarketStallPageViewFirstTime() : void
      {
         if(!Global.player.getSeenFlag(VISITING_MARKET_STALL_FIRST_VIEW))
         {
            Global.player.setSeenFlag(VISITING_MARKET_STALL_FIRST_VIEW);
            FarmStatsManager.sample(100,"farmers_market","friend_market_stall_page","view_page_first_time");
         }
      }
      
      public static function recordFriendMarketStallPageHowDoesWorkClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_inventory_page","click_how_does_this_work");
      }
      
      public static function recordFriendMarketStallPageLeaveStallClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","my_inventory_page","click_leave_stall");
      }
      
      public static function recordHasRewardAvailableOnLogin() : void
      {
         FarmStatsManager.sample(100,"farmers_market","reward_page","reward_available_on_login");
      }
      
      public static function recordRewardPageView(forceFlow:Boolean = false) : void
      {
         if(forceFlow)
         {
            FarmStatsManager.sample(100,"farmers_market","reward_page","view_page","from_building_click");
         }
         else
         {
            FarmStatsManager.sample(100,"farmers_market","reward_page","view_page","from_collect_reward_button_click");
         }
         recordRewardPageViewFirstTime();
      }
      
      private static function recordRewardPageViewFirstTime() : void
      {
         if(!Global.player.getSeenFlag(REWARD_PAGE_FIRST_VIEW))
         {
            Global.player.setSeenFlag(REWARD_PAGE_FIRST_VIEW);
            FarmStatsManager.sample(100,"farmers_market","reward_page","view_page_first_time");
         }
      }
      
      public static function recordRewardChosen(rewardChosen:int) : void
      {
         switch(rewardChosen)
         {
            case CraftingConstants.REWARD_PICK_COINS:
               FarmStatsManager.sample(100,"farmers_market","reward_page","choose_reward","coin");
               break;
            case CraftingConstants.REWARD_PICK_FUEL:
               FarmStatsManager.sample(100,"farmers_market","reward_page","choose_reward","fuel");
               break;
            case CraftingConstants.REWARD_PICK_XP:
               FarmStatsManager.sample(100,"farmers_market","reward_page","choose_reward","XP");
         }
      }
      
      public static function recordInventoryFullPopupPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","inventory_full_pop_up","view_page");
      }
      
      public static function recordInventoryFullPopupShare() : void
      {
         FarmStatsManager.sample(100,"farmers_market","inventory_full_pop_up","click_share");
      }
      
      public static function recordFirstTimeTutorialPopupPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","place_stall_coop_guide","view_page");
      }
      
      public static function recordMarketStallImpulseBuyPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","impulse_buy_pop_up","view_page");
      }
      
      public static function recordMarketStallImpulseBuyCoinClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","impulse_buy_pop_up","buy_coin");
      }
      
      public static function recordMarketStallImpulseBuyCashClick() : void
      {
         FarmStatsManager.sample(100,"farmers_market","impulse_buy_pop_up","buy_cash");
      }
      
      public static function recordReplaceStallPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","replace_stall_pop_up","view_page");
      }
      
      public static function recordReplaceStallAccept() : void
      {
         FarmStatsManager.sample(100,"farmers_market","replace_stall_pop_up","click_replace");
      }
      
      public static function recordFoundBushelSummaryPopupPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","found_bushel_summary_pop_up","view_page");
      }
      
      public static function recordFoundBushelSummaryPopupClickShare() : void
      {
         FarmStatsManager.sample(100,"farmers_market","found_bushel_summary_pop_up","click_share");
      }
      
      public static function recordTakeAllThreeBushelsPageView() : void
      {
         FarmStatsManager.sample(100,"farmers_market","friend_market_stall_page","take_all_three","view_page");
      }
      
      public static function recordTakeAllThreeBushelsClickShare() : void
      {
         FarmStatsManager.sample(100,"farmers_market","friend_market_stall_page","take_all_three","click_share");
      }
      
      public static function recordCottageRailsTutorialStep(tutorialIndex:Number) : void
      {
         switch(tutorialIndex)
         {
            case 0:
               FarmStatsManager.count("crafting_cottage","on_rails_tutorial","start_tutorial");
               break;
            case 1:
               FarmStatsManager.count("crafting_cottage","on_rails_tutorial","click_1st_make_good");
               break;
            case 2:
               FarmStatsManager.count("crafting_cottage","on_rails_tutorial","click_2nd_make_it");
               break;
            case 3:
               FarmStatsManager.count("crafting_cottage","on_rails_tutorial","click_3rd_make_good_tan");
               break;
            case 4:
               FarmStatsManager.count("crafting_cottage","on_rails_tutorial","click_4th_finish_it");
               break;
            case 5:
               FarmStatsManager.count("crafting_cottage","on_rails_tutorial","click_5th_goods_selling");
         }
      }
      
      public static function recordShopForBushelsPageHit() : void
      {
         FarmStatsManager.count("crafting_cottage","recipe_screen_click_get_bushels","shop_for_bushels_page");
      }
      
      public static function recordAskForBushelsPopup() : void
      {
         FarmStatsManager.count("crafting_cottage","recipe_screen_click_get_bushels","ask_for_help_pop_up");
      }
      
      public static function recordAlreadyAskedForBushelsPopup() : void
      {
         FarmStatsManager.count("crafting_cottage","recipe_screen_click_get_bushels","already_asked_for_help_pop_up");
      }
   }
}

