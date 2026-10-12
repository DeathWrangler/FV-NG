package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.ZItem.BuildingItem;
   import Display.UI;
   import Events.FarmGameWorldEvent;
   import Managers.FeatureCraftingManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   
   public class FeatureCraftingIndicatorManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      private const UPDATE_INTERVAL:Number = 5000;
      
      private var m_nextUpdateTime:Number = 0;
      
      public function FeatureCraftingIndicatorManager(owner:FeatureBuilding)
      {
         m_owner = owner;
         m_lookInsideOnClick = true;
         super(owner);
      }
      
      override public function canDisplay() : Boolean
      {
         var result:Boolean = false;
         if(this.getActiveRecipe())
         {
            result = true;
         }
         return result;
      }
      
      override protected function createIndicator(state:String) : void
      {
         var activeRecipe:FeatureCraftingRecipe = null;
         var iconUrl:String = null;
         var arrowState:Object = m_states[state];
         if(arrowState != null)
         {
            activeRecipe = this.getActiveRecipe();
            iconUrl = activeRecipe.iconUrl;
            m_indicator = new ArrowIndicatorWindow(iconUrl,arrowState.title,arrowState.desc,null);
            setIndicatorPosition();
         }
      }
      
      override public function show(state:String = "default") : void
      {
         if(Global.player.postInitFinished)
         {
            super.show(state);
         }
         else
         {
            this.handleDelayedShow(state);
         }
      }
      
      override protected function handleDelayedShow(state:String = "default") : void
      {
         m_delayedShowState = state;
         if(!m_isDelayedShow)
         {
            m_isDelayedShow = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.onDelayedShow,false,0,true);
         }
      }
      
      override protected function onDelayedShow(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.onDelayedShow);
         m_isDelayedShow = false;
         this.show(m_delayedShowState);
      }
      
      override public function update() : void
      {
         var recipe:FeatureCraftingRecipe = null;
         if(GlobalEngine.currentTime > this.m_nextUpdateTime)
         {
            if(!UI.isShowingPopup())
            {
               if(m_indicatorCurrentlyHidden)
               {
                  if(this.canDisplay())
                  {
                     this.show();
                  }
               }
               else
               {
                  recipe = this.getActiveRecipe();
                  if(recipe)
                  {
                     if(recipe.iconUrl != m_indicator.iconUrl)
                     {
                        m_indicator.iconUrl = recipe.iconUrl;
                     }
                  }
                  else
                  {
                     hide();
                  }
               }
            }
            this.m_nextUpdateTime = GlobalEngine.currentTime + this.UPDATE_INTERVAL;
         }
      }
      
      private function getActiveRecipe() : FeatureCraftingRecipe
      {
         var result:FeatureCraftingRecipe = null;
         var buildingItem:BuildingItem = m_owner.getItem() as BuildingItem;
         var system:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystemForBuilding(buildingItem.buildingName);
         if(system)
         {
            result = system.getHighestPriorityRecipeThatIsReady();
         }
         return result;
      }
   }
}

