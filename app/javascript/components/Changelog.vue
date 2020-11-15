<template functional>
  <div class="box-white">
    <h1>Ŝanĝoprotokolo</h1>

    <p>
      Ĉiuj gravaj ŝanĝoj estas dokumentita en ĉi tiu teksto. La teksto-formato
      estas inspirita de
      <a href="https://keepachangelog.com/en/1.0.0/">Keep a Changelog</a>, kaj
      ĉi tiu projeto kongruas kun

      <a href="https://semver.org/spec/v2.0.0.html">Semantic Versioning</a>.
    </p>

    <div>
      <div class="versio">v2.18.7 (2020-11-15)</div>
      <li class="novo">
        [Novo] Aldonas ligilon por listigi retajn eventojn per Webcal.
      </li>
      <li class="riparo">[Riparo] Riparas kronologion pri eventa enhavo</li>
      <li>[Ŝanĝo] Malpligrandigas paĝopiedon</li>
      <li>
        [Ŝanĝo] Kalendara evento kiuj estas multtagaj nun aperas kiel "multtaga"
        anstataŭ "tuttaga"
      </li>
      <li>
        [Ŝanĝo] Ne plu aperigas "Reta, OL" en Webcal eventoj kiam ili estas
        retaj
      </li>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Changelog',
}
</script>

<style scoped lang="scss">
li {
  font-size: 0.9em;
}

.versio {
  font-size: 1.1em;
  font-weight: bold;
  border-bottom: 1px solid lightgrey;
  margin-bottom: 5px;
  margin-top: 2em;
}

.novo {
  color: green;
  font-weight: bold;
}

.riparo {
  color: darkred;
}
</style>
