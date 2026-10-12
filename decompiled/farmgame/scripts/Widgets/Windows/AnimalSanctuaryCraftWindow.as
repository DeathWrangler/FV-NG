package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Managers.AnimalSanctuaryManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryCraftWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      public var m_closeBt:SimpleButton;
      
      private var m_okey_bt:FarmAnimatedTextButton;
      
      private var m_recipeList:Array;
      
      private var m_icon_name_array:Array = ["icon0_mc","icon1_mc","icon2_mc","icon3_mc","icon4_mc"];
      
      private var m_okay_bt_name_array:Array = ["okay0_bt","okay1_bt","okay2_bt","okay3_bt","okay4_bt"];
      
      private var m_name_tf_array:Array = ["text0_tf","text1_tf","text2_tf","text3_tf","text4_tf"];
      
      private var m_icon_mc_array:Array = [];
      
      private var m_name_array:Array = [];
      
      private var m_okay_bt_array:Array = [];
      
      private var m_owner:AnimalSanctuaryMainWindow;
      
      private var m_type:String;
      
      private var m_title_tf:ZwTextField;
      
      private var m_subtitle_tf:ZwTextField;
      
      public function AnimalSanctuaryCraftWindow(featureName:String, assetPath:String, recipeList:Array, owner:AnimalSanctuaryMainWindow, type:String = "Craft")
      {
         this.m_featureName = featureName;
         this.m_recipeList = recipeList;
         if(this.m_recipeList)
         {
            this.m_recipeList = this.m_recipeList.sort();
         }
         this.m_owner = owner;
         this.m_type = type;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var recipeItem:RecipeItem = null;
         var imageUrl:String = null;
         var itemFriendlyTitle:String = null;
         var rewardItem:FarmItem = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_title_tf = new ZwTextField(m_window[this.TITLE_TF],"");
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            this.m_subtitle_tf = new ZwTextField(m_window["subtitle_tf"],"");
         }
         if(this.m_type == "Plant")
         {
            this.m_title_tf.text = "Plant and Harvest";
            this.m_subtitle_tf.text = "Plant and Harvest 100 of a kind to get a coupon drop! More harvest time gives more coupons!";
         }
         else if(this.m_type == "Craft")
         {
            this.m_title_tf.text = "Crafting";
            this.m_subtitle_tf.text = "Craft these items to get a coupon drop!";
         }
         else
         {
            this.m_title_tf.text = "Animal Harvest";
            this.m_subtitle_tf.text = "Harvest 5 of a kind to get a coupon drop! More harvest time more coupons!!";
         }
         this.m_title_tf.visible = true;
         this.m_subtitle_tf.visible = true;
         for(var i:int = 0; i < 5; i++)
         {
            recipeItem = null;
            if(this.m_type == "Craft")
            {
               recipeItem = Global.craftConfigSettings.getRecipeById(this.m_recipeList[i]);
               imageUrl = recipeItem.image;
               itemFriendlyTitle = recipeItem.friendlyTitle;
            }
            else
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_recipeList[i]);
               if(rewardItem)
               {
                  imageUrl = rewardItem.iconUrl;
                  itemFriendlyTitle = rewardItem.friendlyTitle;
               }
            }
            if(m_window.hasOwnProperty(this.m_icon_name_array[i]))
            {
               this.m_icon_mc_array[i] = new FarmIcon(m_window[this.m_icon_name_array[i]]);
               this.m_icon_mc_array[i].loadIcon(imageUrl);
               this.m_icon_mc_array[i].setIconSize(100,100);
               this.m_icon_mc_array[i].visible = true;
            }
            if(m_window.hasOwnProperty(this.m_okay_bt_name_array[i]))
            {
               this.m_okay_bt_array[i] = new FarmAnimatedTextButton(m_window[this.m_okay_bt_name_array[i]],"Craft",this.onSelectCraft(this.m_recipeList[i]));
               this.m_okay_bt_array[i].visible = true;
               if(this.m_type == "Craft")
               {
                  this.m_okay_bt_array[i].text = "Craft";
                  this.m_okay_bt_array[i].callback = this.onSelectCraft(this.m_recipeList[i]);
               }
               else
               {
                  this.m_okay_bt_array[i].text = "Go";
                  this.m_okay_bt_array[i].callback = this.onSelectPlant(this.m_recipeList[i],this.m_type);
               }
            }
            if(m_window.hasOwnProperty(this.m_name_tf_array[i]))
            {
               this.m_name_array[i] = new ZwTextField(m_window[this.m_name_tf_array[i]],itemFriendlyTitle);
               this.m_name_array[i].visible = true;
            }
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
         }
      }
      
      public function onSelectCraft(type:String) : Function
      {
         return function(evt:MouseEvent):void
         {
            close();
            manager.openCraftingCottage(type);
         };
      }
      
      public function onSelectPlant(item:String, type:*) : Function
      {
         return function(evt:MouseEvent):void
         {
            close();
            manager.onClickPlantFromWindow(item,type);
         };
      }
      
      override public function close() : void
      {
         if(this.m_owner)
         {
            this.m_owner.close();
            this.manager.showMainUI();
         }
         super.close();
      }
      
      public function forceClose() : void
      {
         super.close();
      }
      
      private function get manager() : AnimalSanctuaryManager
      {
         return AnimalSanctuaryManager.getInstance();
      }
   }
}

