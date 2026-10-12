package Widgets.Slots.Crafting
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ReportSlot extends ZwSlotFrame
   {
      
      private var m_detailsMC:MovieClip;
      
      private var m_levelUpMC:MovieClip;
      
      private var m_emptyMC:MovieClip;
      
      private var m_detailsFrame:ZwFrame;
      
      private var m_levelUpFrame:ZwFrame;
      
      private var m_emptyFrame:ZwFrame;
      
      public function ReportSlot(element:DisplayObject)
      {
         super(element);
         addWidget(new FarmIcon(m_element.icon_mc));
         (getWidget(m_element.icon_mc) as FarmIcon).setIconSize(40,40);
         this.m_detailsMC = m_element.details_mc;
         this.m_detailsFrame = new ZwFrame(this.m_detailsMC);
         this.m_detailsFrame.addWidget(new ZwTextField(this.m_detailsMC.name_tf));
         this.m_detailsFrame.addWidget(new ZwTextField(this.m_detailsMC.cost_tf));
         this.m_detailsFrame.addWidget(new ZwTextField(this.m_detailsMC.amount_tf));
         this.m_detailsFrame.addWidget(new ZwTextField(this.m_detailsMC.level_tf));
         this.m_detailsFrame.addWidget(new ZwTextField(this.m_detailsMC.friends_tf));
         addWidget(this.m_detailsFrame,false);
         this.m_levelUpMC = m_element.levelUp_mc;
         this.m_levelUpFrame = new ZwFrame(this.m_levelUpMC);
         this.m_levelUpFrame.addWidget(new ZwTextField(this.m_levelUpMC.generic_tf));
         this.m_levelUpFrame.addWidget(new ZwTextField(this.m_levelUpMC.level_tf));
         addWidget(this.m_levelUpFrame,false);
         this.m_emptyMC = m_element.empty_mc;
         this.m_emptyFrame = new ZwFrame(this.m_emptyMC);
         addWidget(this.m_emptyFrame,false);
      }
      
      override public function populate(salesReportItem:Object) : void
      {
         var level:String = null;
         var recipeItem:RecipeItem = null;
         var itemCode:String = null;
         var farmIcon:FarmIcon = null;
         var iconName:String = null;
         var farmItem:FarmItem = null;
         var productName:String = null;
         var productPrice:String = null;
         var amountSold:String = null;
         var extraFriends:int = 0;
         var friends:String = null;
         var recipeId:String = null;
         var recipeNameTK:String = null;
         super.populate(salesReportItem);
         this.m_detailsMC.visible = false;
         this.m_levelUpMC.visible = false;
         this.m_emptyMC.visible = false;
         if(salesReportItem[CraftingConstants.LOGFIELD_ACTION])
         {
            level = salesReportItem[CraftingConstants.LOGDATA_RECIPE_LVL];
            recipeItem = Global.craftConfigSettings.getRecipeById(salesReportItem[CraftingConstants.LOGDATA_RECIPE_ID]);
            if(recipeItem)
            {
               itemCode = recipeItem.productItemCode;
               farmIcon = getWidget(m_element.icon_mc) as FarmIcon;
               iconName = Global.farmGameSettingsManager.getFarmItemByCode(itemCode).icon;
               if(farmIcon)
               {
                  farmIcon.loadIcon(iconName);
                  farmIcon.visible = true;
               }
               switch(salesReportItem[CraftingConstants.LOGFIELD_ACTION])
               {
                  case CraftingConstants.LOGACTION_SOLD:
                     farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                     productName = farmItem.friendlyName;
                     productPrice = salesReportItem[CraftingConstants.LOGDATA_PRICE];
                     amountSold = salesReportItem[CraftingConstants.LOGDATA_QTY];
                     extraFriends = salesReportItem.hasOwnProperty(CraftingConstants.LOGDATA_UID_OVERFLOW) ? int(salesReportItem[CraftingConstants.LOGDATA_UID_OVERFLOW]) : 0;
                     friends = this.getFriendNames(salesReportItem[CraftingConstants.LOGDATA_UID],extraFriends);
                     this.m_detailsMC.visible = true;
                     (this.m_detailsFrame.getWidget(this.m_detailsMC.name_tf) as ZwTextField).text = ZLocUtils.tk_pk_asTitle(productName);
                     (this.m_detailsFrame.getWidget(this.m_detailsMC.cost_tf) as ZwTextField).text = ZLocUtils.t("Crafting","SalesReport_Price",{"quantity":productPrice});
                     (this.m_detailsFrame.getWidget(this.m_detailsMC.amount_tf) as ZwTextField).text = ZLocUtils.t("Crafting","SalesReport_AmountSold",{"quantity":amountSold});
                     (this.m_detailsFrame.getWidget(this.m_detailsMC.level_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingCottages_Level",{"quantity":level});
                     (this.m_detailsFrame.getWidget(this.m_detailsMC.friends_tf) as ZwTextField).text = friends;
                     break;
                  case CraftingConstants.LOGACTION_RECIPE_LVL:
                     recipeId = salesReportItem[CraftingConstants.LOGDATA_RECIPE_ID];
                     recipeNameTK = Global.craftConfigSettings.getRecipeById(recipeId).friendlyName + "_recipe";
                     this.m_levelUpMC.visible = true;
                     (this.m_levelUpFrame.getWidget(this.m_levelUpMC.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","SalesReport_LevelUp",{"itemRecipe":ZLocUtils.tk_pk(recipeNameTK)});
                     (this.m_levelUpFrame.getWidget(this.m_levelUpMC.level_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingCottages_Level2",{"quantity":level});
               }
            }
         }
         else
         {
            this.m_emptyMC.visible = true;
         }
      }
      
      private function getFriendNames(friendUids:Array, extraFriends:int) : String
      {
         var i:int = 0;
         var uid:String = null;
         var friend:Friend = null;
         var result:String = "";
         var friendNames:Array = [];
         var friendGenders:Array = [];
         if(friendUids)
         {
            for(i = 0; i < friendUids.length; i++)
            {
               uid = friendUids[i];
               if(uid != "0")
               {
                  friend = Global.friendManager.getFriendData(uid);
                  if(friend)
                  {
                     friendNames.push(friend.firstName);
                     friendGenders.push(Global.friendManager.getFriendGender(uid));
                  }
               }
               else if(uid == "-1")
               {
                  friendNames.push("Farmville");
                  friendGenders.push("masc");
               }
            }
         }
         if(friendNames.length == 1)
         {
            result = ZLocUtils.t("Crafting","SalesReport_BoughtBy1",{"friend":ZLocUtils.tn(friendNames[0],ZLocUtils.tg(friendGenders[0]))});
         }
         if(friendNames.length == 2)
         {
            result = ZLocUtils.t("Crafting","SalesReport_BoughtBy2",{
               "friendA":ZLocUtils.tn(friendNames[0],ZLocUtils.tg(friendGenders[0])),
               "friendB":ZLocUtils.tn(friendNames[1],ZLocUtils.tg(friendGenders[1]))
            });
         }
         if(friendUids.length == 3 && extraFriends <= 0)
         {
            result = ZLocUtils.t("Crafting","SalesReport_BoughtBy3",{
               "friendA":ZLocUtils.tn(friendNames[0],ZLocUtils.tg(friendGenders[0])),
               "friendB":ZLocUtils.tn(friendNames[1],ZLocUtils.tg(friendGenders[1])),
               "friendC":ZLocUtils.tn(friendNames[2],ZLocUtils.tg(friendGenders[2]))
            });
         }
         if(friendUids.length == 3 && extraFriends > 0)
         {
            extraFriends++;
            result += ZLocUtils.t("Crafting","SalesReport_BoughtByMore",{
               "friendA":ZLocUtils.tn(friendNames[0],ZLocUtils.tg(friendGenders[0])),
               "friendB":ZLocUtils.tn(friendNames[1],ZLocUtils.tg(friendGenders[1])),
               "quantity":extraFriends.toString()
            });
         }
         return result;
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

