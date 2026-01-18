<template>
  <div :style="`height: ${sectionHeight}px`">
    <div
      class="paralax-bg paralax-content-wrapper"
      :style="`height: ${paralaxHeight}px; 
                background-color: ${headerOverlayColor};` "
    >
      <div
        class="paralax-img"
        :style="`height: ${paralaxHeight}px;
                  background: url(${image});
                  background-attachment: fixed;
                  background-repeat: no-repeat;
                  background-size: cover;
                  background-position: center center;`"
      ></div>
      <div
        class="paralax-content"
        data-sal="zoom-in"
        data-sal-delay="150"
        data-sal-duration="500"
        data-sal-easing="ease-out-bounce"
      >
        <span
          v-bind:class="[brightText ? 'text-white' : 'text-black']"
          class="text-h1 title-paralax"
        >{{ title }}</span>
        <span
          v-if="showCoupleName"
          v-bind:class="[brightText ? 'text-white' : 'text-black']"
          class="text-h2 title2-paralax"
        >{{ coupleName }}</span>
        <!-- Spacer -->
        <div
          style="flex: 1"
          v-if="
                showCoupleName &&
                showDate &&
                (showGuestName || (showInvitationButton && canConfirm))
              "
        ></div>
        <span
          v-if="showDate"
          v-bind:class="[brightText ? 'text-white' : 'text-black']"
          class="text-h2 title2-paralax"
        >{{ moment(weddingDate).format("DD.MM.YYYY") }}</span>
        <!-- Spacer -->
        <div style="flex: 1" v-if="showGuestName || (showInvitationButton && canConfirm)"></div>
        <span
          v-if="showGuestName"
          v-bind:class="[brightText ? 'text-white' : 'text-black']"
          class="text-h2 title2-paralax"
        >{{ $t("hello") }}, {{ user.invitationname }}</span>
        <q-btn
          v-if="showInvitationButton && canConfirm"
          rounded
          :color="brightText ? 'white' : 'black'"
          :text-color="brightText ? 'primary' : 'white'"
          :label="$t('confirmNow') + '...'"
          class="btn-paralax q-mt-xs"
          @click="navToConfirmSection()"
        />
      </div>
    </div>
    <div
      v-if="$q.screen.gt.md && showCountdown"
      class="row justify-center align-center countdown-wrapper"
    >
      <countdown class="countdown-item" :date="countdown"></countdown>
    </div>
  </div>
</template>
<style lang="scss">
.countdown-item {
  width: 100%;
  max-width: 650px;
}
.countdown-wrapper {
  min-height: 185px;
  background-color: var(--q-primary);
}
.paralax-img {
  position: absolute;
  width: 100%;
  z-index: -1;
}

@media (max-width: 599px) {
  .paralax-img {
    background-attachment: scroll !important;
  }
}

.paralax-content-wrapper {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  flex: 1;
  width: 100%;
}
.paralax-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  flex: 1;
  width: 100%;
  max-height: 500px;
  padding: 1em;
}
.title-paralax {
  font-family: "Clicker Script", cursive;
  text-align: center;
}
.title2-paralax {
  font-family: "Clicker Script", cursive;
  text-align: center;
}
.btn-paralax {
  font-size: 20px;
}

@media (max-width: 450px) {
  .title-paralax {
    font-size: 4.5rem;
    line-height: 4.5rem;
  }
  .title2-paralax {
    font-size: 3rem;
    line-height: 3rem;
  }
  .titledate-paralax {
    font-size: 1.725rem;
    font-weight: 400;
    line-height: 2rem;
  }
  .btn-paralax {
    font-size: 16px;
  }
}
</style>
<script>
import sal from "sal.js";
import countdown from "components/_intern/countdown";
import { defineComponent } from "vue";
import { debounce, colors } from "quasar";
import { mapState, mapGetters } from "vuex";
import moment from "moment";

export default defineComponent({
  name: "StartSection",
  components: {
    countdown
  },
  data() {
    return {
      initHeight: 0,
      sectionHeight: 0,
      paralaxHeight: 0,
      countdownHeight: 185,
      headerHeight: 51,
      moment: moment
    };
  },
  created() {
    this.initHeight = this.$q.screen.height;
    this.calculateHeights(this.initHeight);

    this.debounceResize = this.$_.debounce(this.onResize, 300);
    window.addEventListener("resize", debounce(this.debounceResize, 300));
  },
  mounted() {
    sal();
  },
  unmounted() {
    window.removeEventListener("resize", this.onResize);
  },
  computed: {
    ...mapState({
      title: (state) => state.content.header.title,
      user: (state) => state.user.user,
      brightText: (state) => state.content.header.brightText,
      showCoupleName: (state) => state.content.header.showCoupleName,
      showDate: (state) => state.content.header.showDate,
      showGuestName: (state) =>
        state.content.header.showGuestName &&
        state.user.user &&
        !state.user.user.isGroupInvitation,
      showInvitationButton: (state) =>
        state.content.header.showInvitationButton,
      showCountdown: (state) => state.content.header.showCountdown
    }),
    ...mapGetters({
      canConfirm: "user/canConfirm",
      headerOverlayColor: "content/headerOverlayColor",
      weddingDate: "basedata/weddingDate",
      coupleName: "basedata/coupleName",
      countdown: "basedata/countdown",
      image: "content/headerImage"
    })
  },
  methods: {
    onResize() {
      const tmpHeight = this.$q.screen.height;
      const threshold = 100;
      /* first check if the screen height change more than a specif number
        in mobile the url bar is changing height on scrolling so it would be
        come to a weird side effect
      */
      if (Math.abs(tmpHeight - this.initHeight) > threshold) {
        this.initHeight = this.$q.screen.height;
        this.calculateHeights(this.initHeight);
      }
    },
    calculateHeights(screenHeight) {
      this.sectionHeight = screenHeight - this.headerHeight;
      this.paralaxHeight =
        this.sectionHeight -
        (this.$q.screen.gt.md && this.showCountdown ? this.countdownHeight : 0);
    },
    navToConfirmSection() {
      this.$store.dispatch("content/navToConfirmSection");
    }
  }
});
</script>
