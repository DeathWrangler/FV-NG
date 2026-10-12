package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.feed.CraftingCottageFeed;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Crafting.RecipeMasteryWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class RecipeMasteryShareFrame extends ZwFrame
   {
      
      protected var m_feed:CraftingCottageFeed;
      
      protected var m_window:RecipeMasteryWindow;
      
      public function RecipeMasteryShareFrame(element:MovieClip, recipe:RecipeItem, level:int, rewardLink:String, parent:RecipeMasteryWindow)
      {
         var cottageName:String = null;
         var localizationObj:Object = null;
         super(element);
         this.m_window = parent;
         var goodLevel:int = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipe.id).level;
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","Mastery_ShareText",{
            "levelNum":goodLevel,
            "recipe":ZLocUtils.tk_pk(recipe.friendlyName)
         })));
         var iconUrl:String = Global.farmGameSettingsManager.getFarmItemByCode(recipe.productItemCode).icon;
         var icon:FarmIcon = new FarmIcon(m_element.icon_mc,iconUrl);
         icon.setIconHeight(60);
         icon.setIconWidth(60);
         addWidget(icon);
         if(Global.player.masterySignEnabled())
         {
            addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t("Dialogs","ShareButton"),this.onShare));
            addWidget(new FarmAnimatedTextButton(m_element.cancel_bt,ZLocUtils.t("Dialogs","Cancel"),this.onClose));
            cottageName = CraftingManager.getInstance().getCottageFriendlyNameByCraft(recipe.craft);
            localizationObj = {
               "cottage":cottageName,
               "item":recipe.friendlyName,
               "level":level
            };
            this.m_feed = new CraftingCottageFeed("crafting_recipe_mastery",rewardLink,localizationObj);
            this.m_feed.setImage(recipe.getMasterySignIcon(level),true);
         }
         else
         {
            addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t("Dialogs","Continue"),this.onShare),false);
            addWidget(new FarmAnimatedTextButton(m_element.cancel_bt,ZLocUtils.t("Dialogs","Cancel"),this.onClose),false);
         }
      }
      
      protected function onShare(e:MouseEvent) : void
      {
         if(Global.player.masterySignEnabled())
         {
            if(this.m_feed)
            {
               this.m_feed.publish();
            }
            FarmStatsManager.count("RecipeMastery","share");
         }
         this.onClose(e);
      }
      
      protected function onClose(e:MouseEvent) : void
      {
         this.m_window.close();
      }
      
      override public function release() : void
      {
         this.m_window = null;
         this.m_feed = null;
         super.release();
      }
   }
}

