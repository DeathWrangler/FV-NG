package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.ImageLoader;
   import Classes.Plot;
   import Classes.feed.OilBarronFeed;
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class AMFertilize extends AMActionState
   {
      
      private static var m_effectLoader:ImageLoader = null;
      
      private static var m_effect:DisplayObject = null;
      
      private static var m_fuelLoader:ImageLoader = null;
      
      private var m_fuelEffect:DisplayObject = null;
      
      public const ENERGY_PER_FIFTHTANK:int = 30;
      
      private var m_plot:Plot;
      
      private var m_fuel:int;
      
      private var m_fuelFeed:OilBarronFeed;
      
      private var m_playOnReenter:Boolean = true;
      
      private var m_startAnimation:Boolean = false;
      
      public function AMFertilize(avatar:FarmAvatar, plot:Plot)
      {
         var effectURL:String = null;
         super(avatar,plot);
         this.m_plot = plot;
         var fuelDiscovery:Object = Global.player.fuelDiscovery;
         if(Boolean(fuelDiscovery) && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            this.m_fuel = fuelDiscovery.amount;
            this.m_fuelFeed = new OilBarronFeed(Global.worldManager.getVisiting(),fuelDiscovery.rewardLink);
            Global.player.fuelDiscovery = null;
         }
         if(m_effectLoader == null)
         {
            effectURL = Plot.FERTILIZE_SUCCESS_URL;
            m_fuelLoader = ImageLoader.getInstance(Global.getAssetURL(Plot.FERTILIZE_FUELSUCCESS_URL));
            m_effectLoader = ImageLoader.getInstance(Global.getAssetURL(effectURL));
         }
         m_fuelLoader.getContent(this.onFuelLoad);
         m_effectLoader.getContent(this.onEffectLoad);
      }
      
      public function onEffectLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         m_effect = dispObj;
         m_effect.visible = false;
         m_effect.scaleX = 1;
         m_effect.scaleY = 1;
      }
      
      public function onFuelLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_fuelEffect = dispObj;
         this.m_fuelEffect.visible = false;
         this.m_fuelEffect.scaleX = 1;
         this.m_fuelEffect.scaleY = 1;
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var plotDisplayObjectSprite:Sprite = null;
         var effect:DisplayObject = null;
         if(m_actionStarted && m_avatar != null)
         {
            if(this.m_plot != null && this.m_plot.isFertilizable() && this.m_plot.getDisplayObject() as Sprite != null)
            {
               if(!this.m_startAnimation && m_effect != null && this.m_fuelEffect != null)
               {
                  plotDisplayObjectSprite = this.m_plot.getDisplayObject() as Sprite;
                  if(this.m_fuel > 0)
                  {
                     effect = this.m_fuelEffect;
                     effect.y = -1 * (this.m_fuelEffect.loaderInfo.height / 2);
                     plotDisplayObjectSprite.alpha = 1;
                  }
                  else
                  {
                     effect = m_effect;
                  }
                  this.m_startAnimation = true;
                  plotDisplayObjectSprite.addChildAt(effect,plotDisplayObjectSprite.numChildren - 1);
                  (effect as MovieClip).gotoAndStop(1);
                  effect.visible = true;
                  (effect as MovieClip).gotoAndPlay(1);
               }
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("fertilizeTime");
               if(progress > 1)
               {
                  Global.player.energy += this.m_fuel * this.ENERGY_PER_FIFTHTANK;
                  if(this.m_fuel > 0)
                  {
                     Global.hud.flashFuelBar();
                     this.m_fuelFeed.startFeedFlow();
                  }
                  this.m_plot.fertilize();
                  if(m_effect != null && this.m_fuelEffect != null)
                  {
                     (m_effect as MovieClip).visible = false;
                     (this.m_fuelEffect as MovieClip).visible = false;
                  }
                  m_avatar.getStateMachine().removeState(this);
               }
               else
               {
                  m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Fertilizing"),progress);
               }
            }
            else
            {
               m_avatar.getStateMachine().removeState(this);
            }
         }
      }
      
      override public function added() : void
      {
         super.added();
         this.m_plot.setActionState(HarvestableResource.IS_FERTILIZING);
      }
      
      override public function enter() : void
      {
         super.enter();
         if(!this.conditionallyPath() || this.m_actionStarted)
         {
            this.m_playOnReenter = false;
            SoundManager.chooseAndPlaySound(["plow1","plow2","plow3"]);
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(this.m_playOnReenter && this.m_actionStarted)
         {
            SoundManager.chooseAndPlaySound(["plow1","plow2","plow3"]);
         }
      }
      
      override public function removed() : void
      {
         var plotDisplayObjectSprite:Sprite = null;
         super.removed();
         this.m_plot.setActionState(HarvestableResource.IS_RESTING);
         if(this.m_fuel > 0)
         {
            plotDisplayObjectSprite = this.m_plot.getDisplayObject() as Sprite;
            plotDisplayObjectSprite.removeChildAt(plotDisplayObjectSprite.numChildren - 1);
         }
      }
   }
}

